#sample user script
Import-Module .\CredentialManager.psd1

$Environment = "prod"
$PwdHashPath = $HOME+"\Documents\HashStore"
if (Test-Path $PwdHashPath) {New-Item -Type Directory -Force -Path $PwdHashPath }


#Username/Password with hash from current session user
$AdminUserSample        = "adminTest"
$AdminUserSamplehash    = Get-PasswordHash -id $AdminUserSample -Environment $Environment -EnvironmentUser $env:USERNAME -System $env:COMPUTERNAME -HashPath $PwdHashPath

#create credential object
$credentialAdminSample = New-Object System.Management.Automation.PSCredential $AdminUserSample, $AdminUserSamplehash

#Username/Password with hash from current machine
$AdminUserSample2        = "adminTest2"
$AdminUserSamplehash2    = Get-PasswordHash -id $AdminUserSample2 -Environment $Environment -EnvironmentUser $env:USERNAME  -System $env:COMPUTERNAME -HashPath $PwdHashPath -Machine $true

#create credential object
$credentialAdminSample2 = New-Object System.Management.Automation.PSCredential $AdminUserSample2, $AdminUserSamplehash2


#Import-Moule AzureAD
#$Connect-AzureAD -Credential $credentialAdminSample

#$cmd = ("mssql-cli -U {0} -P {1} -d {2} -S {4} -Q {5}" -f $credentialAdminSample2.UserName, $credentialAdminSample2.GetNetworkCredential().Password, "myDB", "dbServer", "Selet * from myTable")
#$ret = Invoke-Expression $cmd
# process $ret

write-host "finished"