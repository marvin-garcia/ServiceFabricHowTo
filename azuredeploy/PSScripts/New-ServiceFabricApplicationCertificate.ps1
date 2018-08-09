Param
(
    [Parameter(Mandatory=$true)]
    [String]
    $vaultName,

    [Parameter(Mandatory=$true)]
    [String]
    $ClusterResourceGroupName,

    [Parameter(Mandatory=$true)]
    [String]
    $ClusterName,

    [String]
    $SubscriptionId = $null
)

Write-Host "Do you want to log in to Azure? [y/n]"
$ans = Read-Host
if ($ans -eq 'y')
{
    Login-AzureRmAccount -ErrorAction Stop
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
}

$cluster = Get-AzureRmServiceFabricCluster -ResourceGroupName $ClusterResourceGroupName -Name $ClusterName -Verbose -ErrorAction Stop

$SubjectName = "$($cluster.Name)-$($cluster.Location)-DataEnciphermentCert"
$certPassword = ConvertTo-SecureString -String ([Guid]::NewGuid().ToString()) -AsPlainText -Force
$filePath = "$([System.IO.Path]::GetTempPath())\$([System.IO.Path]::GetRandomFileName()).pfx"

# Create a self signed cert, export to PFX file.
New-SelfSignedCertificate `
    -Type DocumentEncryptionCert `
    -KeyUsage DataEncipherment `
    -Subject $SubjectName `
    -Provider 'Microsoft Enhanced Cryptographic Provider v1.0' `
    -Verbose `
    -ErrorAction Stop `
| Export-PfxCertificate `
    -FilePath $filePath `
    -Password $certPassword `
    -Verbose `
    -ErrorAction Stop

# Import the certificate to an existing key vault. The key vault must be enabled for deployment.
$cer = Import-AzureKeyVaultCertificate `
    -VaultName $vaultName `
    -Name $SubjectName `
    -FilePath $filePath `
    -Password $certPassword `
    -Verbose `
    -ErrorAction Stop
rm $filePath -Force -Verbose

# Add the certificate to all the VMs in the cluster.
Add-AzureRmServiceFabricApplicationCertificate `
    -ResourceGroupName $ClusterResourceGroupName `
    -Name $ClusterName `
    -SecretIdentifier $cer.SecretId `
    -Verbose `
    -ErrorAction Stop