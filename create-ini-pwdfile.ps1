[CmdletBinding()]
param(  
               [Parameter(Mandatory=$true, HelpMessage="Enter a loginId!")]
			   [string]$id
)
. $env:scriptroot\Global\globaldomains.ps1
$cred = get-credential $id
$cred.password|convertFrom-SecureString| % {$pwd=$_}
$uid=$($cred.UserName)
$uid=$uid.replace("\","-")
$uid=$uid.replace("@","-")
$fn = ("init-pwd-{0}-{1}-{2}.ps1" -f $Environment, $EnvironmentUser, $uid)
remove-item $fn -ErrorAction SilentlyContinue
Add-Content -path $fn  "# ***********************************************************************************************"
Add-Content -path $fn  "# Variables"
Add-Content -path $fn  "#ServiceAccount with secured password"
Add-Content -path $fn  "`$Acc1 = `"$($cred.UserName)`""
Add-Content -path $fn  "`$pwd1 = `"$pwd`""
Add-Content -path $fn  "# ***********************************************************************************************"
write-host "encryption file $fn created"