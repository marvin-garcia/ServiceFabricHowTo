<#
Requires -Module AzureRM.KeyVault

Use this script to create a certificate that you can use to secure a Service Fabric Cluster
This script requires an existing KeyVault that is EnabledForDeployment.  The vault must be in the same region as the cluster.
Once the certificate is created and stored in the vault, the script will provide the parameter values needed for template deployment
#>

param(
    [string] [Parameter(Mandatory=$true)] $Password,
    [string] [Parameter(Mandatory=$true)] $CertName,
    [string] [Parameter(Mandatory=$true)] $CertDNSName,
    [string] [Parameter(Mandatory=$true)] $CertFileFullPath,
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultSecretName
)

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$NewCert = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName $CertDNSName -Verbose -ErrorAction Stop
Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $NewCert -Verbose -ErrorAction Stop

$Bytes = [System.IO.File]::ReadAllBytes($CertFileFullPath)
$Base64 = [System.Convert]::ToBase64String($Bytes)

$JSONBlob = @{
    data = $Base64
    dataType = 'pfx'
    password = $Password
} | ConvertTo-Json

$ContentBytes = [System.Text.Encoding]::UTF8.GetBytes($JSONBlob)
$Content = [System.Convert]::ToBase64String($ContentBytes)

$SecretValue = ConvertTo-SecureString -String $Content -AsPlainText -Force
#$NewSecret = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -SecretValue $SecretValue -Verbose -ErrorAction Stop
$VaultCert = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $CertName -FilePath $CertFileFullPath -Password $SecurePassword -Verbose -ErrorAction Stop

Write-Host
Write-Host "Cert local path: $($CertFileFullPath)"
Write-Host "Source Vault Resource Id: "$(Get-AzureRmKeyVault -VaultName $KeyVaultName).ResourceId
Write-Host "Certificate URL : "$VaultCert.Id
Write-Host "Certificate Thumbprint : "$NewCert.Thumbprint
