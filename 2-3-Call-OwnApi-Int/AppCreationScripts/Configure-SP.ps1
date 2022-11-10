[CmdletBinding()]
param(
    [PSCredential] $Credential,
    [Parameter(Mandatory=$True, HelpMessage='Tenant ID (This is a GUID which represents the "Directory ID" of the AzureAD tenant into which you want to create the apps')]
    [string] $tenantId,
    [Parameter(Mandatory=$True, HelpMessage='Service App ID (This is a GUID which represents the ID (application id) of the previously created service app from the other AzureAD tenant')]
    [string] $serviceAppId,
    [Parameter(Mandatory=$True, HelpMessage='Service App Display Name (This is a name displayed for the app of the previously created service app from the other AzureAD tenant')]
    [string] $serviceAppDisplayName
)

Function ConfigureApplications
{
    <#.Description
    This function creates the Azure AD applications for the sample in the provided Azure AD tenant and updates the
    configuration files in the client and service project  of the visual studio solution (App.Config and Web.Config)
    so that they are consistent with the Applications parameters
    #> 

    # Login to Azure PowerShell (interactive if credentials are not already provided:
    # you'll need to sign-in with creds enabling your to create apps in the tenant)
    if (!$Credential -and $TenantId)
    {
        $creds = Connect-AzureAD -TenantId $tenantId
    }
    else
    {
        if (!$TenantId)
        {
            $creds = Connect-AzureAD -Credential $Credential
        }
        else
        {
            $creds = Connect-AzureAD -TenantId $tenantId -Credential $Credential
        }
    }

    if (!$tenantId)
    {
        $tenantId = $creds.Tenant.Id
    }

    $tenant = Get-AzureADTenantDetail
    $tenantName =  ($tenant.VerifiedDomains | Where { $_._Default -eq $True }).Name

    # Get the user running the script
    $user = Get-AzureADUser -ObjectId $creds.Account.Id

    # Create the service principal for the service AAD application in the client tenant
    Write-Host "Creating the service principal for the service application (id:$serviceAppId, name:$serviceAppDisplayName)."
    New-AzureADServicePrincipal -AppId $serviceAppId -DisplayName $serviceAppDisplayName

    Write-Host "Service principal for the service application created (id:$serviceAppId, name:$serviceAppDisplayName)."
}

   # Pre-requisites
if ((Get-Module -ListAvailable -Name "AzureAD") -eq $null) { 
    Install-Module "AzureAD" -Scope CurrentUser 
} 
Import-Module AzureAD

# Run interactively (will ask you for the tenant ID)
ConfigureApplications -Credential $Credential -tenantId $TenantId