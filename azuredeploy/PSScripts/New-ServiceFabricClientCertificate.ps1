Param
(
    [String] [ValidateSet('Admin', 'ReadOnly')] $CertificateType,
    [String] [Parameter(Mandatory = $true)] $ClusterResourceGroupName,
    [String] [Parameter(Mandatory = $true)] $ClusterName,
    [string] [Parameter(Mandatory = $true)] $Password,
    [string] [Parameter(Mandatory = $true)] $CertFileFullPath,
    [string] $SubscriptionId = $null
)

Write-Host "Do you want to log in to Azure? [y/n]"
$ans = Read-Host
if ($ans -eq 'y')
{
    Login-AzureRmAccount -ErrorAction Stop
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
}

$cluster = Get-AzureRmServiceFabricCluster -ResourceGroupName $ClusterResourceGroupName -Name $ClusterName -Verbose -ErrorAction Stop

$SubjectName = "$($cluster.Name).$($cluster.Location)-$($CertificateType)Cert"
$CertStoreLocation = "Cert:\CurrentUser\My"

Write-Host -ForegroundColor Cyan "VERBOSE: Creating self-signed certificate..."

# Create a self signed cert.
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$newCert = New-SelfSignedCertificate `
    -Type Custom `
    -KeyUsage DigitalSignature `
    -Subject "CN=$SubjectName" `
    -CertStoreLocation $CertStoreLocation `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$SubjectName") `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Verbose -ErrorAction Stop
Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $newCert -Verbose -ErrorAction Stop

# Add the certificate to all the VMs in the cluster.
switch ($CertificateType)
{
    'Admin'
    {
        $cluster = Add-AzureRmServiceFabricClientCertificate -Admin `
            -ResourceGroupName $ClusterResourceGroupName `
            -Name $ClusterName `
            -Thumbprint $newCert.Thumbprint `
            -Verbose -ErrorAction Stop
    }
    'ReadOnly'
    {
        $cluster = Add-AzureRmServiceFabricClientCertificate `
            -ResourceGroupName $ClusterResourceGroupName `
            -Name $ClusterName `
            -Thumbprint $newCert.Thumbprint `
            -Verbose -ErrorAction Stop
    }
}

Write-Host -ForegroundColor Yellow "Subject Name: $($newCert.Subject)"
Write-Host -ForegroundColor Yellow "Thumbprint: $($newCert.Thumbprint)"

Write-Host
Write-Host "Cert local path: $($CertFileFullPath)"
Write-Host "Certificate Thumbprint : "$NewCert.Thumbprint
