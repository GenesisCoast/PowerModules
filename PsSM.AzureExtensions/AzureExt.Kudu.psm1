function Remove-AzureWebAppPath(
    [Parameter(Mandatory)][string] $WebAppName,
    [Parameter(Mandatory)][string] $Path,
    [Parameter(Mandatory)][string] $ResourceGroupName
) {
    try {
        $base64Credential = Get-AzurePublishingCredential `
            -WebAppName $WebAppName `
            -ResourceGroupName $ResourceGroupName

        $commandBody = @{
            dir     = "site\\wwwroot"
            command = "rm $Path -d -r"
        }

        Invoke-RestMethod `
            -Method POST `
            -Body (ConvertTo-Json $commandBody) `
            -Headers @{Authorization = ("Basic $base64Credential")} `
            -Uri "https://$WebAppName.scm.azurewebsites.net/api/command" `
        | Out-Null
    }
    catch {
        Write-Error ("$Path failed to delete for the Azure Web App $WebAppName.
            $_.Exception.Message `n
            $_.Exception.StackTrace"
        )
    }
}

function Publish-AzureWebApp(
    [Parameter(Mandatory)][string] $WebAppName,
    [Parameter(Mandatory)][String] $SourceFolder,
    [Parameter(Mandatory)][string] $ResourceGroupName
) {
    try {
        Compress-Archive `
            -DestinationPath ".\_out.zip" `
            -Path (Get-ChildItem $SourceFolder -Exclude @(".vscode", ".gitignore", "appsettings.json", "secrets"))

        $base64Credential = Get-AzurePublishingCredential $WebAppName $ResourceGroupName
        Invoke-RestMethod `
            -Verbose `
            -Method PUT `
            -InFile $ZipFilePath `
            -ContentType "multipart/form-data" `
            -Headers @{Authorization = ("Basic $base64Credential")} `
            -Uri "https://$($WebAppName).scm.azurewebsites.net/api/zip/site/wwwroot" `
    }
    catch {
        Write-Error ("$ZipFilePath failed to deploy to the Azure Web App $WebAppName. 
            $_.Exception.Message `n
            $_.Exception.StackTrace"
        )
    }
    finally {
        Remove-Item ".\_out.zip" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Remove-AzureWebAppRoot(
    [Parameter(Mandatory)][string] $WebAppName,
    [Parameter(Mandatory)][string] $ResourceGroupName
) {
    Remove-AzureWebAppPath `
        -Path "wwwroot/*" `
        -WebAppName $WebAppName `
        -ResourceGroupName $ResourceGroupName
}

function Get-AzureWebAppPublishingCredential(
    [Parameter(Mandatory)][string] $WebAppName,
    [Parameter(Mandatory)][string] $ResourceGroupName
) {
    $credentials = $(Invoke-AzureRmResourceAction `
        -Force `
        -Action list `
        -ApiVersion 2015-08-01 `
        -ResourceGroupName $ResourceGroupName `
        -ResourceType Microsoft.Web/sites/config `
        -ResourceName "$WebAppName/publishingcredentials"
    ).Properties

    return ([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(
        "$($credentials.PublishingUserName):$($credentials.PublishingPassword)"
    )))
}

Export-ModuleMember -Function Check-*
Export-ModuleMember -Function Compress-*
Export-ModuleMember -Function Publish-*
Export-ModuleMember -Function Remove-*
Export-ModuleMember -Function Get-*

