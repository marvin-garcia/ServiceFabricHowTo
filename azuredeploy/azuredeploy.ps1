cls
$parameters = @{
    "clusterLocation" = "southcentralus"
    "clusterName" = "statefulservicetest"
    "adminPassword" = "Passw0rd!"
    "dnsName" = "statefulservicetest"
    "vmImagePublisher" = "MicrosoftWindowsServer"
    "vmImageOffer" = "WindowsServerSemiAnnual"
    "vmImageSku" = "Datacenter-Core-1709-with-Containers-smalldisk"
    "certificateThumbprint" = "58EFBEB41C6317423846C4F7E715F258A9F1E5AC"
    "sourceVaultValue" = "/subscriptions/f0cf2edb-86a7-44b6-9c02-9c5fee5c618d/resourceGroups/ServiceFabricStatefulTest/providers/Microsoft.KeyVault/vaults/SvcFabricServiceVault"
    "certificateUrlValue" = "https://svcfabricservicevault.vault.azure.net/secrets/statefulservicetestClusterCert/f18f5a20328b4057ba035646fb18a6e3"
    "clientCertificateCommonName" = "CN=statefulservicetest.southcentralus.cloudapp.azure.com"
    "clientCertificateThumbprint" = "58EFBEB41C6317423846C4F7E715F258A9F1E5AC"
    "vmNodeType0Name" = "Bronze"
    "vmNodeType0Size" = "Standard_DS3_v2"
}

$template = "C:\Users\magar\source\repos\ServiceFabricHowTo\azuredeploy\azuredeploy-sf-1709-custom-docker-root-dir.json"

New-AzureRmResourceGroupDeployment `
    -Name ServiceFabric `
    -ResourceGroupName ServiceFabricStatefulTest `
    -Mode Incremental `
    -TemplateFile $template `
    -TemplateParameterObject $parameters `
    -Verbose `
    -Force