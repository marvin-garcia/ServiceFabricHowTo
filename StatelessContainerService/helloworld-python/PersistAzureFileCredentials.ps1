Param(
    [string]$FileShareEndPointHost,
    [string]$StorageAccountName,
    [string]$StorageAccountKey
)

# The cmdkey utility is a command-line (rather than PowerShell) tool. We use Invoke-Expression to allow us to 
# consume the appropriate values from the storage account variables. The value given to the add parameter of the
# cmdkey utility is the host address for the storage account, <storage-account>.file.core.windows.net for Azure 
# Public Regions. $storageAccount.Context.FileEndpoint is used because non-Public Azure regions, such as soverign 
# clouds or Azure Stack deployments, will have different hosts for Azure file shares (and other storage resources).

$command = "cmdkey /add:$($FileShareEndPointHost) /user:AZURE\$($StorageAccountName) /pass:$($storageAccountKey)"
Invoke-Expression -Command $command