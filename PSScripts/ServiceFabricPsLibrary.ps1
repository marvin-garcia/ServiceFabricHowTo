function New-ServiceFabricClusterCertificate
{
   param(
        [string] [Parameter(Mandatory=$true)] $Password,
        [string] [Parameter(Mandatory=$true)] $CertName,
        [string] [Parameter(Mandatory=$true)] $CertDNSName,
        [string] [Parameter(Mandatory=$true)] $CertFileFullPath,
        [string] [Parameter(Mandatory=$true)] $KeyVaultName
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
    $VaultCert = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $CertName -FilePath $CertFileFullPath -Password $SecurePassword -Verbose -ErrorAction Stop

    Write-Host
    Write-Host "Cert local path: $($CertFileFullPath)"
    Write-Host "Source Vault Resource Id: "$(Get-AzureRmKeyVault -VaultName $KeyVaultName).ResourceId
    Write-Host "Certificate URL : "$VaultCert.Id
    Write-Host "Certificate Thumbprint : "$NewCert.Thumbprint

    return @{
        "path" = $CertFileFullPath
        "vaultResourceId"= $(Get-AzureRmKeyVault -VaultName $KeyVaultName).ResourceId
        "certificateUrl" = $VaultCert.Id
        "certificateThumbprint" = $NewCert.Thumbprint
    }
}