# CredentialManagement

The module is designed to store and retrieve a password safely. The stored password is either encrypted with users session private key or on local machine level.
User session based encryption is preferred. However using windows remote management winrm from Linux there are issue with user session based approach and machine level encryption/decryption may solve the issue.

The password hashes are stored in the location $PwdHashPath. Directory is created if needed. 
The variable $Environment is used to have multiple password for the same id for different environments, like dev, qa and prod. If not used just leave it prod.
The variable $System is used to define the crendtials set for a defined. THis is important if you run CI/CD envroment and all code is centrally.

By executing the code below the module prompts for a password if a non valid hash or no hash file exists.

For automation tasks under an service account a password hash MUST be generated under service account context (runas).

to use the module check the sample-use.ps1 script.

AS shown in the example th cript can work as a wrapper for normal batch file (bat/cmd) execution where otjwrwise passwords would be exposed.


Note: remember to be logged in with correct user to execute a script. Machine Level encryption/decryption please use only when needed.
