$Class = Get-ChildItem -Path .\Classes\*.cs -file -Recurse
Foreach($CLS in $Class){
	Write-Verbose -Message "Class File: $CMD"  
	$Content = Get-Content -raw -path $CLS
    Add-Type -TypeDefinition $Content
}

$Commands = Get-ChildItem -Path $PSScriptRoot\PrivateCommands\*.ps1 -file -Recurse
Foreach($PCMD in $Commands){
	Write-Verbose -Message "Private Cmdlet File: $PCMD"  
	. $PCMD
}

$Script:Blobs = @{}
$Commands = Get-ChildItem -Path $PSScriptRoot\blobs\*.ps1 -file -Recurse
Foreach($Blob in $Commands){
	Write-Verbose -Message Blob File: $Blob"  
	$Content = Get-Content -raw -path $Blob
	[void] $Script:Blobs.add($Blob.Basename,$Content)
}

$Commands = Get-ChildItem -Path $PSScriptRoot\Commands\*.ps1 -file -Recurse
Foreach($CMD in $Commands){
	Write-Verbose -Message "Cmdlet File: $CMD"  
	. $CMD
}