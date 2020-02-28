$Commands = Get-ChildItem -Path $PSScriptRoot\Commands\*.ps1 -file -Recurse
Foreach($CMD in $Commands){
	Write-Verbose -Message "File: $CMD"  
	. $CMD
}