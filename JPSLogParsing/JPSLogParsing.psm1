if (Test-Path -Path $PSScriptRoot\Classes\){
    $Class = Get-ChildItem -Path $PSScriptRoot\Classes\*.cs -file -Recurse
    Foreach($CLS in $Class){
	    Write-Verbose -Message "Class File: $CMD"  
	    $Content = Get-Content -raw -path $CLS
        Add-Type -TypeDefinition $Content
    }
}

if (Test-Path -Path $PSScriptRoot\PrivateCommands\){
    $Commands = Get-ChildItem -Path $PSScriptRoot\PrivateCommands\*.ps1 -file -Recurse
    Foreach($PCMD in $Commands){
	    Write-Verbose -Message "Private Cmdlet File: $PCMD"  
	    . $PCMD
    }
}

$Script:Blobs = @{}
if (Test-Path -Path $PSScriptRoot\blobs\){
    $BlobFiles = Get-ChildItem -Path $PSScriptRoot\blobs\*.* -file -Recurse
    Foreach($Blob in $BlobFiles){
	    Write-Verbose -Message "Blob File: $Blob"  
	    $Content = Get-Content -raw -path $Blob
	    [void] $Script:Blobs.add($Blob.Basename,$Content)
    }
}

if (Test-Path -Path $PSScriptRoot\Commands\){
    $Commands = Get-ChildItem -Path $PSScriptRoot\Commands\*.ps1 -file -Recurse
    Foreach($CMD in $Commands){
	    Write-Verbose -Message "Cmdlet File: $CMD"  
	    . $CMD
    }
}