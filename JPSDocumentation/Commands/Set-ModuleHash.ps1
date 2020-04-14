Function Get-MDHelp
{
  <#
      .Synopsis
        Build the documentation based on the region information and comment information of a script
    
      .DESCRIPTION
      Author:    Jeff Scripter
      Modified:  Jeff Scripter

      Purpose: 
        This script is designed to provide a mechanism to document a script based on the comments and 

      Return:
        Formated scraping of the comments


      .NOTES
      Overview:
        1) Reads File
        2) Uses Regex to extract regions, #- comments and endregions
        3) adjust lines based on nested regions
        4) outputs

      Comment:	
 
      Assumptions:	
      1) Region fields are followed by the nested number (IE: #region 1). This is used to indent the regions and make them more readable
      2) any comment that should be included has a dash after the number symbol (IE: #-)
    
    
      Changes:
        2016_08_23 - Original - Jeff Scripter - Original


      Test Script: 
      1) Run against known well formatted script.

      .EXAMPLE

  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    # Path to script
    [ValidateScript({Test-Path $_})]
    [String] $Path

  )
    
  Begin
  {
    $component = "$($MyInvocation.InvocationName)-1.0.0"
    
    $HelpHeader = Get-Help $Path -Full
    $ScriptComments = ''
    $tabNumber = 0
  }
  
  Process
  {
    $Comments = get-content $Path | select-string '^\s*#(-|region|endregion)'

    Foreach ($line in $comments){
      # format tabs
      $line = $line.tostring().split('#')[1]
      Switch ($true)
      {
        #begin Region
        ($line -like 'region*')
        {
          $line = "`n`r" + "`t"*$tabNumber + $line
          $tabNumber++
          $Expected = [regex]::matches($line,'\d')[0].value
          If ($tabNumber -NE $Expected)
          {
            Write-Warning -message "$component -Line number not expected $tabNumber : $line"
          }
        }
    
        #finish region
        ($line -like 'endregion*')
        {
          $tabNumber--
          $Expected = [regex]::matches($line,'\d')[0].value -1
          $line =  "`t"*$tabNumber + $line + "`n`r"
          If ($tabNumber -NE $Expected)
          {
            Write-Warning -message "$component-Line number not expected $tabNumber : $line" 
          }
        }
    
        #sub Comments 
        Default
        {
          $line = "`t"*$tabNumber + $line
        }
      }
      $ScriptComments = "$ScriptComments`n$line"
    }
    $ScriptComments = "
      Synopsis:
        $($HelpHeader.Synopsis)

      $($HelpHeader.Description.text)

      $($HelpHeader.alertSet.alert.text)
      
      $($ScriptComments.replace("`n`n","`n"))"
  }
  
  End
  {
    Return $ScriptComments
  }
}
