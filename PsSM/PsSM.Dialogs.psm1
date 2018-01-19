function Get-OpenFileDialog(
    [Parameter(Mandatory = $false)][string] $InitialDir = [Environment]::GetFolderPath("Desktop")
) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.Filter = "CSV Files (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null

    return $OpenFileDialog.FileName
}

Export-ModuleMember -Function Get-*
