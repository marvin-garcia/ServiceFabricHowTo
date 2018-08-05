$text = "6v+nDbZ5Ox/Lr+DVaBGUBjxUWYcUEURx"
Invoke-ServiceFabricEncryptText -CertStore -CertThumbprint $cer.Thumbprint -Text $text -StoreLocation Local -StoreName My