function Check-AzureRmResourceGroup([Parameter(Mandatory)][string] $Name) {
    if (-not $(Get-AzureRmResourceGroup $Name -ErrorAction SilentlyContinue)) {
        Write-Host "Resource group '$Name' does not exist."
        $location = Read-Host "ResourceGroupLocation (Full)"

        Write-Host "Creating resource group '$Name' in location '$location'"
        New-AzureRmResourceGroup $Name -Location $location
    }
    else {
        Write-Host "Using existing resource group '$Name'"
    }
    return $Name
}

function Login-AzureRmServicePrincipal (
    [Parameter(Mandatory)][Alias("Username")][string] $ClientId,
    [Parameter(Mandatory)][Alias("Password")][string] $ClientSecret,
    [Parameter(Mandatory = $false)][Alias("SubscriptionId")][string] $TenantId = "e352209c-2734-4a03-a6ba-d4ee6f2ed11e"
) {
    $credential = New-Object System.Management.Automation.PSCredential(
        $ClientId, 
        (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))

    Login-AzureRmAccount -ServicePrincipal -TenantId $TenantId -Credential $credential
}

function Login-ToAzureRmOncePerSession {
    if ([string]::IsNullOrEmpty((Get-AzureRmContext -ErrorAction SilentlyContinue).Account)) { 
        Login-AzureRmAccount 
    }
    else {
        Get-AzureRmContext
    }
}


Export-ModuleMember -Function Check-*
Export-ModuleMember -Function Login-*