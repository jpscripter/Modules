#Invoke-MSIQuery -MSIPath $msipath -query 'Select `Table`, Name from _Columns'
#Invoke-MSIQuery -MSIPath $msipath -Table '_Columns'
#https://docs.microsoft.com/en-us/windows/win32/msi/sql-syntax
#Like operator not supported

Function Invoke-MSIQuery { 
    param(
        [parameter(Mandatory=$true,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$MSIPath,
    
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$MSTPath,
    
        [parameter(Mandatory=$False,ParameterSetName='Table')]
        [ValidateNotNullOrEmpty()]
        [string]$Table = '_Tables',
    
        [parameter(Mandatory=$True,ParameterSetName='Query')]
        [ValidateNotNullOrEmpty()]
        [string]$Query
    )
    Begin{
        #Setup Objects
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        [PSCustomObject[]]$Return = $Null

    }
    Process {
        # Read property from MSI database
        $readonly = 0
        Try{
            $MSIDatabase =  $WindowsInstaller.OpenDatabase($MSIPath.FullName, $readonly)
        }
        Catch{
            Throw 'Can not read MSI'
            Return
        }

        If($MSTPath){
            Try{
                $MSIDatabase.ApplyTransform($MSTPath,$readonly)
            }
            Catch{
                Write-Warning -Message "$MSIPath Can not apply $MSTPath"
            }
        }

        [string[]]$Columns = $null
        if ($PSCmdlet.ParameterSetName -eq 'Table'){
           $Query = "Select * from $Table"
        }

        Try{
            Write-Verbose -Message "Query $MsiPath : $query"
            $View = $MSIDatabase.OpenView($Query)
            $View.Execute()

            #Get Column names
            $ColumnRecord =$view.GetType().InvokeMember("ColumnInfo", "GetProperty", $null, $View, 0) 
            $Columns = @()
            $Counter = 1
            Do {
                $ColumnName = $ColumnRecord.GetType().InvokeMember("StringData", "GetProperty", $null, $ColumnRecord, $Counter)
                if(-not [String]::IsNullOrWhiteSpace($ColumnName))
                {
                    $Columns +=  $ColumnName 
                }
                $Counter++
            }While ( -not [String]::IsNullOrWhiteSpace($ColumnName) -and $ColumnRecord.count -GE 1)
            Write-Debug -Message "Columns: $($Columns -join ',')"
            
            $Record = $View.Fetch()
            While ($Record)
            { 
                $Row = @{}
                For($i = 0; $i -lt $Columns.count;$i++){
                    $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, $i +1)
                    $Null = $Row.Add($Columns[$i],$Value)
                }
                $Return += [PSCustomObject] $Row
                $Record = $View.Fetch()
            }
        }   
        Catch
        {
            $Record = $WindowsInstaller.LastErrorRecord()
            [String] $row = ''
            For($i = 0; $i -lt 7;$i++){
                $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, $i +1)
                if ([string]::IsNullOrWhiteSpace($Value))
                {
                    $i = 8
                }Else{
                    $Row += $Value + '|'
                }
            }
            Write-Warning -Message $PSItem
            Write-Warning -Message " MSI Error: $row" 
            Return
        }
         # Commit database and close view
        Finally{
            $View.Close()
            $MSIDatabase.Commit()
        }
    }
    End {
        # Run garbage collection and release ComObject
        $MSIDatabase = $null
        $View = $null
        [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) 
        [System.GC]::Collect()
        Return $return
        }
    }
