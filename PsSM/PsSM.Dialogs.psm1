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

function Get-YesNoDialog() {
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Continues the Operation"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Aborts the Operation"
    
    if ($choice = $host.ui.PromptForChoice(
            "Are you sure?", 
            'Do you want to delete all Secrets [Y]es or [N]o?', 
            [System.Management.Automation.Host.ChoiceDescription[]] ($yes, $no), 
            0
    ) -eq 1) {
        Exit
    }
}

Export-ModuleMember -Function Get-*
