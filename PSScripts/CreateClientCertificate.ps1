Param
(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Admin', 'ReadOnly')]
    [String]
    $CertificateType,
        
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

$SubjectName = "$($cluster.Name).$($cluster.Location)-$($CertificateType)Cert"
$CertStoreLocation = "Cert:\CurrentUser\My"

Write-Host -ForegroundColor Cyan "VERBOSE: Creating self-signed certificate..."

# Create a self signed cert.
$newCert = New-SelfSignedCertificate `
    -Type Custom `
    -KeyUsage DigitalSignature `
    -Subject "CN=$SubjectName" `
    -CertStoreLocation $CertStoreLocation `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$SubjectName") `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Verbose

# Add the certificate to all the VMs in the cluster.
switch ($CertificateType)
{
    'Admin'
    {
        $cluster = Add-AzureRmServiceFabricClientCertificate -Admin `
            -ResourceGroupName $ClusterResourceGroupName `
            -Name $ClusterName `
            -Thumbprint $newCert.Thumbprint `
            -Verbose
    }
    'ReadOnly'
    {
        $cluster = Add-AzureRmServiceFabricClientCertificate `
            -ResourceGroupName $ClusterResourceGroupName `
            -Name $ClusterName `
            -Thumbprint $newCert.Thumbprint `
            -Verbose
    }
}

Write-Host -ForegroundColor Yellow "Subject Name: $($newCert.Subject)"
Write-Host -ForegroundColor Yellow "Thumbprint: $($newCert.Thumbprint)"