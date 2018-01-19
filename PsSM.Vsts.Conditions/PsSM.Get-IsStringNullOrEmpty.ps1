<# 
    .SYNOPSIS
        Checks if the Input string is NullOrEmpty
	.INPUTS
		-Input			An Empty or Null String can be entered.
	.NOTES
        Version:        1.0
        Author:         Harry Sanderson
        Creation Date:  19/01/18
        Purpose/Change: Initial script development
	.LINKS
		https://github.com/GenesisCoast/Powershell.SupremeModules
    .EXAMPLE
        PsSM.Get-IsStringNullOrEmpty.ps1
#>

param(
	[AllowNull()][AllowEmptyString()][string] $Input
)

if ([string]::IsNullOrEmpty($Input)) {
	throw "[NullOrEmpty] Input is NullOrEmpty."
}