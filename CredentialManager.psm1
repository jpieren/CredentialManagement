# ***********************************************************************************************
# Credential Manager functions
# ***********************************************************************************************
#
# function to prompt for a password and encrypt password either under user or machine context and save the hash
function newpassword2file {
	param (
		[parameter (Mandatory=$true, position=1)]
		$id,
		[parameter (Mandatory=$true, position=2)]
		$Environment,
		[parameter (Mandatory=$true, position=3)]
		$EnvironmentUser,
		[parameter (Mandatory=$true, position=4)]
		$System,
		[parameter (Mandatory=$true, position=5)]
		$hashPath,
		[parameter (Mandatory=$false, position=6)]
		$Machine
	)

	begin {
		$cred = get-credential $id
	}
	process {
		if ($machine) {
			# creatae hash with localmaschine protection scope
			$password = $cred.GetNetworkCredential().Password
			$PasswordBytes = [System.Text.Encoding]::Unicode.GetBytes($password)
			$SecurePassword = [Security.Cryptography.ProtectedData]::Protect($PasswordBytes, $null, [Security.Cryptography.DataProtectionScope]::LocalMachine)
			$SecurePasswordStr = [System.Convert]::ToBase64String($SecurePassword)
		} else {
			$cred.password|convertFrom-SecureString| % {$SecurePasswordStr=$_}
		}
		
		$uid=$($cred.UserName)
		$uid=$uid.replace("\","-")
		$uid=$uid.replace("@","-")
		$fn = ("{0}\pwd-{1}-{2}-{3}-{4}.ps1" -f $hashPath, $Environment, $System, $EnvironmentUser, $uid)
		remove-item $fn -ErrorAction SilentlyContinue
		Add-Content -path $fn  "# ***********************************************************************************************"
		Add-Content -path $fn  "# Variables"
		Add-Content -path $fn  "#ServiceAccount with secured password"
		Add-Content -path $fn  "`$Acc1 = `"$($cred.UserName)`""
		Add-Content -path $fn  "`$pwd1 = `"$SecurePasswordStr`""
		Add-Content -path $fn  "# ***********************************************************************************************"
		$msg = "encryption file $fn created"
		Write-Information $msg
	}
	end {

	}
}

function Get-PasswordHash {

	param (
		[parameter (Mandatory=$true, position=1)]
		$id,
		[parameter (Mandatory=$true, position=2)]
		$Environment,
		[parameter (Mandatory=$true, position=3)]
		$EnvironmentUser,
		[parameter (Mandatory=$true, position=4)]
		$System,
		[parameter (Mandatory=$true, position=5)]
		$hashPath,
		[parameter (Mandatory=$false, position=6)]
		$Machine=$false
	)

	begin {
		$uid=$id.replace("\","-")
		$uid=$uid.replace("@","-")			
		$fn = ("{0}\pwd-{1}-{2}-{3}-{4}.ps1" -f $hashPath, $Environment, $System, $EnvironmentUser, $uid)
		write-host $fn
	}
	Process {
		if (!(Test-Path $fn)) {
			$msg = ("No hash exists in environment/{0} for EnvUser/userID {1}/{2}`n`nCreate hash file with .\create-ini-pwdfile.ps1" -f $Environment, $EnvironmentUser, $uid)
			Write-Warning $msg
			newpassword2file -id $id -Environment $Environment -System $System -EnvironmentUser $EnvironmentUser -hashPath $hashPath -Machine $Machine
		}
		. $fn
		# check if we can decryp
	
		if ($Machine) {
			try {
				$SecureStr = [System.Convert]::FromBase64String($pwd1)
				$StringBytes = [Security.Cryptography.ProtectedData]::Unprotect($SecureStr, $null, [Security.Cryptography.DataProtectionScope]::LocalMachine)
				$PasswordStr = [System.Text.Encoding]::Unicode.GetString($StringBytes)
				} catch {
					write-Warning "$E"
					write-Warning "$user"
					newpassword2file -id $id -Environment $Environment $EnvironmentUser $EnvironmentUser -hashPath $hashPath -Machine $Machine
					. $fn
				}
				$passwordHash = $PasswordStr | ConvertTo-SecureString -asPlainText -Force
		} else {
			$passwordHash = ConvertTo-SecureString $pwd1 -ErrorAction SilentlyContinue -ErrorVariable E
			if (![string]::IsNullOrEmpty($e)) {
				write-Warning "$E"
				write-Warning "$user"
				newpassword2file -id $id -Environment $Environment -EnvironmentUser $EnvironmentUser -hashPath $hashPath -Machine $Machine
				. $fn
				$passwordHash= $passwordSecStr | convertFrom-SecureString
			}
		}
	}
	end {
		return $passwordHash
	}
}			
#-------------------------------------------
Export-ModuleMember -Function Get-PasswordHash