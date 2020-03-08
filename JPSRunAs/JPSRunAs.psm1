$Class = Get-ChildItem -Path .\Classes\*.cs -file -Recurse
Foreach($CLS in $Class){
	Write-Verbose -Message "Class File: $CMD"  
	$Content = Get-Content -raw -path $CLS
    Add-Type -TypeDefinition $Content
}

$Commands = Get-ChildItem -Path $PSScriptRoot\Commands\*.ps1 -file -Recurse
Foreach($CMD in $Commands){
	Write-Verbose -Message "Cmdlet File: $CMD"  
	. $CMD
}

