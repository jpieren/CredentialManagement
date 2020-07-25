# CredentialManagement

The module is designed to store and retrieve a password safefly. The stored password is is either encryped with users session private key or on local machine level.
User session based encryption is preferrfed. However using windows remote management winrm from Linux there are issue with user session based approach and machinbe level encryoption/deccryption may solve the issue.

The password hashes are stored in the location in the below example under $PwdPath. The variable $Environment is used to have mutluplle passord for the same id for different environments, like dev, qa and prod. If not used just leave it prod.

By executing the code below the module prompts for a password if a non valid hash or no hash exists.

For automation tasks under an service account a password hash MUST be generated under service account conext (runas).



#sample user script
import-module credentialManager
$Environment = "prod"
$PwdPath = $HOME+"\Documents\hashStore"


#Username/Password with hash from current session user
$AdminUserSample        = "adminTest"
$AdminUserSamplehash    = Get-Hash -id $AdminUserSample -env $Environment -EnvironmentUser $env:USERNAME -path $PwdPath
$AdminUserSamplepwd     = ConvertTo-SecureString $AdminUserSamplehash -ErrorAction SilentlyContinue -ErrorVariable E

#create credential object
$credentialAdminSample = New-Object System.Management.Automation.PSCredential $AdminUserSamplehash, $AdminUserSamplepwd

#Username/Password with hash from current machine
$AdminUserSample2        = "adminTest2"
$AdminUserSamplehash2    = Get-Hash -id $AdminUserSample -env $Environment -EnvironmentUser $env:USERNAME -path $PwdPath -Machine $true
$AdminUserSamplepwd2 = ConvertTo-SecureString $AdminUserSamplehash2 -ErrorAction SilentlyContinue -ErrorVariable E

#create credential object
$credentialAdminSample2 = New-Object System.Management.Automation.PSCredential $AdminUserSamplehash2, $AdminUserSamplepwd2

