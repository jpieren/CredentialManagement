#-------------------------------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------------------------------
# create password hash to file
function cupwdFile {
		param ($id, $Environment, $EnvironmentUser)
		$cred = get-credential $id
		$cred.password|convertFrom-SecureString| % {$pwd=$_}
		$uid=$($cred.UserName)
		$uid=$uid.replace("\","-")
		$uid=$uid.replace("@","-")
		$fn = ("{0}\Global\init-pwd-{1}-{2}-{3}.ps1" -f $env:ScriptRoot, $Environment, $EnvironmentUser, $uid)
		remove-item $fn -ErrorAction SilentlyContinue
		Add-Content -path $fn  "# ***********************************************************************************************"
		Add-Content -path $fn  "# Variables"
		Add-Content -path $fn  "#ServiceAccount with secured password"
		Add-Content -path $fn  "`$Acc1 = `"$($cred.UserName)`""
		Add-Content -path $fn  "`$pwd1 = `"$pwd`""
		Add-Content -path $fn  "# ***********************************************************************************************"
		write-host "encryption file $fn created"
}
#------------------------
# get password hash from file
function  Get-Hash {
	param (	[string]$Env,
			[string]$user,
			[string]$path)

	$id=$user.replace("\","-")
	$id=$id.replace("@","-")			
	$fn = ("{0}\Global\init-pwd-{1}-{2}-{3}.ps1" -f $env:ScriptRoot, $env, $EnvironmentUser, $id)
	write-host $fn
	if (!(Test-Path $fn)) {
		write-warning ("No hash exists in environment/User {0}/{1} for userID {2}`n`nCreate hash file with .\create-ini-pwdfile.ps1 -id" -f $env,$EnvironmentUser, $user)
		cupwdFile $user $Environment $EnvironmentUser
	}
	. $fn
	# check if we can decryp
	$pwdHash = ConvertTo-SecureString $pwd1 -ErrorAction SilentlyContinue -ErrorVariable E
	if (![string]::IsNullOrEmpty($e)) {
		write-Warning "$E"
		write-Warning "$user"
		cupwdFile $user $Environment $EnvironmentUser
	}
	
	return $pwd1
}			
