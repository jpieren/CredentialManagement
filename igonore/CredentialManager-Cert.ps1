$CertificateName = "CredentialModule"
$OutputPFXPath  = "$CertificateName.pfx"
$OutputCERPath = "$CertificateName.cer"
$Password = Get-Credential -UserName Certificate -Message "Enter a secure password:"

$certificate = New-SelfSignedCertificate -subject $CertificateName -Type CodeSigning -CertStoreLocation "cert:\CurrentUser\My"
$pfxCertificate = Export-PfxCertificate $certificate -FilePath $OutputPFXPath -password $Password.password
Export-Certificate -Cert $certificate -FilePath $OutputCERPath
Import-PfxCertificate $pfxCertificate -CertStoreLocation cert:\CurrentUser\Root -Password $password.password
Write-Output "Private Certificate '$CertificateName' exported to $OutputPFXPath"
Write-Output "Public Certificate '$CertificateName' exported to $OutputCERPath"