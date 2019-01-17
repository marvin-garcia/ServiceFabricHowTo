Function New-ServiceFabricClusterCertificate
{
    Param(
        [String]$Password,
        [String]$ResourceGroupName,
        [String]$KeyVaultName,
        [String]$ClusterName,
        [String]$CertName = $ClusterName + "ClusterCert",
        [String]$location,
        [String]$CertDNSName = $ClusterName + "." + $location + ".cloudapp.azure.com",
        [String]$PFXFileLocation,
        [String]$CertStoreLocation = "Cert:\CurrentUser\My"
    )

    $CertFileFullPath = [System.IO.Path]::Combine($PFXFileLocation, "$($ClusterName)-Cluster-Cert.pfx")
    
    # Create resource group if does not exist
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force -ErrorAction Stop

    # Create key vault if does not exist
    $KeyVault = Get-AzureRmKeyVault -ResourceGroupName $ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
    if (!$KeyVault)
    {
        New-AzureRmKeyVault -ResourceGroupName $ResourceGroupName -Name $KeyVaultName -Location $location -EnabledForDeployment -EnabledForTemplateDeployment -Sku Standard -ErrorAction Stop
    }

    #Create the cluster key
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $NewCert = New-SelfSignedCertificate -CertStoreLocation $CertStoreLocation -DnsName $CertDNSName -Verbose -ErrorAction Stop
    Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $NewCert -Verbose -ErrorAction Stop
    Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $CertFileFullPath -Password $SecurePassword -Verbose -ErrorAction Stop

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
    $VaultCert = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $CertName -FilePath $CertFileFullPath -Password $SecurePassword -Verbose -ErrorAction Stop

    Write-Host
    Write-Host "Cert local path: $($CertFileFullPath)"
    Write-Host "Cert Thumbprint : $($NewCert.Thumbprint)"
    Write-Host "Cert URL : $($VaultCert.Id)"
    Write-Host "Secret URL: $($VaultCert.SecretId)"

    return
}