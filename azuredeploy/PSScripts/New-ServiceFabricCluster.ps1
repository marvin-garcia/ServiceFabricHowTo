param
(
    [String] [Parameter(Mandatory = $true)] $ResourceGroupName,
    [String] [Parameter(Mandatory = $true)] $location,
    [String] [Parameter(Mandatory = $true)] $KeyVaultName,
    [String] [Parameter(Mandatory = $true)] $ClusterName,
    
    [string] [Parameter(Mandatory = $true)] $ClusterCertPassword,
    [string] [Parameter(Mandatory = $true)] $ClusterCertName,
    [string] [Parameter(Mandatory = $true)] $ClusterCertDNSName,
    [string] [Parameter(Mandatory = $true)] $ClusterCertFileFullPath,

    [string] [Parameter(Mandatory = $true)] $ClusterAdminUsername,
    [string] [Parameter(Mandatory = $true)] $ClusterAdminPassword,

    [string] [Parameter(Mandatory = $true)] [ValidateSet('2016-Datacenter', 'Datacenter-Core-1709-smalldisk')] $ClusterImageSku,
    [String] $ClusterImageVersion = "latest"
)

#Create resource group and key vault
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force -Verbose -ErrorAction Stop
New-AzureRmKeyVault -ResourceGroupName $ResourceGroupName -Name $KeyVaultName -Location $location -EnabledForDeployment -Sku Standard -Verbose -ErrorAction Stop

#region Create cluster certificate
$SecurePassword = ConvertTo-SecureString -String $ClusterCertPassword -AsPlainText -Force
$NewCert = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName $ClusterCertDNSName -Verbose -ErrorAction Stop
Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $NewCert -Verbose -ErrorAction Stop
$VaultCert = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $ClusterCertName -FilePath $ClusterCertFileFullPath -Password $SecurePassword -Verbose -ErrorAction Stop

Write-Host
Write-Host "Cert local path: $($CertFileFullPath)"
Write-Host "Source Vault Resource Id: "$(Get-AzureRmKeyVault -VaultName $KeyVaultName).ResourceId
Write-Host "Certificate URL : "$VaultCert.Id
Write-Host "Certificate Thumbprint : "$NewCert.Thumbprint
Write-Host
#endregion


$ClusterImagePublisher = "MicrosoftWindowsServer"
switch ($ClusterImageSku)
{
    "2016-Datacenter" { $ClusterImageOffer = "WindowsServer" }
    "Datacenter-Core-1709-smalldisk" { $ClusterImageOffer = "WindowsServerSemiAnnual" }
}
$ClusterImageVersion = "latest"

$params = @{
    "location" = $location
    "clusterName" = $ClusterName
    "adminUsername" = $ClusterAdminUsername
    "adminPassword" = $ClusterAdminPassword
    "vmImagePublisher" = $ClusterImagePublisher
    "vmImageOffer" = $ClusterImageOffer
    "vmImageSku" = $ClusterImageSku
    "vmImageVersion" = $ClusterImageVersion
    "loadBalancedAppPort1" = 80
    "loadBalancedAppPort2" = 8081
    "certificateStoreValue" = "My"
    "certificateThumbprint" = $newcert.
    "sourceVaultResourceId": {
        "type": "string",
        "metadata": {
        "description": "Resource Id of the key vault, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.KeyVault/vaults/<vault name>"
        }
    },
    "certificateUrlValue": {
        "type": "string",
        "metadata": {
        "description": "Refers to the location URL in your key vault where the certificate was uploaded, it is should be in the format of https://<name of the vault>.vault.azure.net:443/secrets/<exact location>"
        }
    },
    "clusterProtectionLevel": {
        "type": "string",
        "allowedValues": [
        "None",
        "Sign",
        "EncryptAndSign"
        ],
        "defaultValue": "EncryptAndSign",
        "metadata": {
        "description": "Protection level.Three values are allowed - EncryptAndSign, Sign, None. It is best to keep the default of EncryptAndSign, unless you have a need not to"
        }
    },
    "nt0InstanceCount": {
        "type": "int",
        "defaultValue": 5,
        "metadata": {
        "description": "Instance count for node type"
        }
    },
    "nodeDataDrive": {
        "type": "string",
        "defaultValue": "Temp",
        "allowedValues": [
        "OS", "Temp"
        ],
        "metadata": {
        "description": "The drive to use to store data on a cluster node."
        }
    },
    "nodeTypeSize": {
        "type": "string",
        "defaultValue": "Standard_D2_v2",
        "metadata": {
        "description": "The VM size to use for cluster nodes."
        }
    }
    }