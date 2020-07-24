# ***********************************************************************************************
# param ($RootPath)
# ***********************************************************************************************
# Variables
#
param (
    $overwrite = $null
)
$global:Delimiter = ","
$globaL:ArrayDelimiter = "|"

if (!$Environment) {
	Write-Host "please invoke first global domains first"
	exit
}
#------------------------
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
#-------------------------------------------
$Environments = @{

'prod'=@{
'Root' = 'D:\O365identities\Provisioning';
'OutPut' = 'output';
'log'='logs';
'input'='input';
'tmp'='tmp';
'prefixCred'='init-prod-';
'pathDLL'= "$env:ProgramFiles\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI"; 
'pathModule'= '\Modules';
'AdminUserADSPI' = 'spi\sao365identities';
'AdminUserADhashSPI' = '';
'AdminUserADNOAM' = 'sujjp@swissport-usa.com';
'AdminUserADhashNOAM' = '';
'AdminUserADCORP' = 'corp\sao365identities';
'AdminUserADhashCORP' = '';

'RootOUSPI' = 'DC=swissport,DC=aero';
'RootOUNOAM' = 'DC=swissport-usa,DC=com';
'RootOUCORP' = 'DC=corp,DC=ads,DC=swissport,DC=aero';
'WriteRootOUSPI' = 'OU=ORGANIZATION,OU=GLOBAL,DC=swissport,DC=aero';
'WriteRootOUCORP' = 'OU=Organisation,DC=corp,DC=ads,DC=swissport,DC=aero';
'WriteRootOUexceptionSPI' = @{
	'hqi'='OU=HQI,OU=ORGANIZATION,OU=GLOBAL,DC=swissport,DC=aero';
}
'WriteRootOUexceptionCORP' = @{
}
'DCSPI' = 'DETCSASPMS0133.swissport.aero';
'DCCORP' = 'detcsaspms0004.corp.ads.swissport.aero';
'DCNOAM' = 'detcsaspms0140.Swissport-usa.com'; #  'spnaad02.Swissport-usa.com' 'DCCV-ADC1001.swissport-usa.com';

# ext 3 migrated means coming for US or SPI but now in corp --> modify/delete in corp
# ext3 = provsionied means new to corp --> new/modify/delete in corp
# ext3 = <empty> not migrated just check spi then to delete
'MigrationAttribute' = 'extensionAttribute3';
'LicenseAttribute' = 'extensionAttribute10';
'MPCcodeAttribute' = 'extensionAttribute11';
'CitrixTSUsers' = 'SG_XA_O365Desktop';
'CitrixTSGroups' = 'SG-XA-O365-SharedUserDesktop';
'RemoteDomain' = 'swissport.mail.onmicrosoft.com';
'UsageLocation' = 'CH';
'AdminUserAzure' = 'svc.o365identities@swissport.onmicrosoft.com';
'AdminUserAzurehash' = '';
'daysUntilDelete' = '30'; # '1'; !!!!!!!! for testing!!!!!!!!
'MailAlertEmail' = 'Global.O365-Identity@Swissport.com';#'jay.pieren@swissport.com';
'MailFrom' = 'provisioningO365@swissport.com';
'MailHost' = 'smtp.swissport.aero';
'onPremAB' = @(
	'CN=All Users,CN=All Address Lists,CN=Address Lists Container,CN=Swissport,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=swissport,DC=aero',
	'CN=Default Global Address List,CN=All Global Address Lists,CN=Address Lists Container,CN=Swissport,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=swissport,DC=aero'
	);
ID=999}
}

# Licenses
$Licenses = @{
'F1' 	= @{
	'ServiceType' 		= 'Collaboration Minimal';
	'AccountSku' 		= 'swissport:DESKLESSPACK';
	'PlansDisabled' 	=  @("OFFICEMOBILE_SUBSCRIPTION","SWAY","FLOW_O365_S1","POWERAPPS_O365_S1","TEAMS1","Deskless","FORMS_PLAN_K","BPOS_S_TODO_FIRSTLINE");
	'ADGroup'			= 'AG-O365-E1-Licensed-Users';
	'Type'				= 'Base'
	'BaseType'			= 'E1'
	'ADGroupTS'			= 'AG-o365_E1_users'; 

	}
'E1' 	= @{
	'ServiceType' 		= 'Collaboration Basic';
	'AccountSku' 		= 'swissport:STANDARDPACK';
	'PlansDisabled' 	=  @("PROJECTWORKMANAGEMENT","SWAY","FLOW_O365_P1","POWERAPPS_O365_P1","TEAMS1","Deskless","FORMS_PLAN_E1","BPOS_S_TODO_1");
	'ADGroup'			= 'AG-O365-E1-Licensed-Users';
	'Type'				= 'Base'
	'BaseType'			= 'E1'
	'ADGroupTS'			= 'AG-o365_E1_users'; 

	}
'E3' = @{
	'ServiceType'	 	= 'Collaboration Pro';
	'AccountSku'		= 'swissport:ENTERPRISEPACK';
	'PlansDisabled' 	=  @("PROJECTWORKMANAGEMENT","SWAY","RMS_S_ENTERPRISE","FLOW_O365_P2","POWERAPPS_O365_P2","TEAMS1","Deskless","FORMS_PLAN_E3","BPOS_S_TODO_2");
	'ADGroup'			= 'AG-O365-E3-Licensed-Users' ;
	'Type'				= 'Base'
	'BaseType'			= 'E3'
	'ADGroupTS'			= 'AG-o365_E3_users'; 
	}
'E5' = @{
	'ServiceType'	 	= 'Collaboration Premium';
	'AccountSku'		= 'swissport:ENTERPRISEPREMIUM';
	'PlansDisabled' 	=  @("PROJECTWORKMANAGEMENT","SWAY","RMS_S_ENTERPRISE","FLOW_O365_P3","POWERAPPS_O365_P3","TEAMS1","Deskless","BI_AZURE_P2","THREAT_INTELLIGENCE","LOCKBOX_ENTERPRISE","ADALLOM_S_O365","EQUIVIO_ANALYTICS","EXCHANGE_ANALYTICS","FORMS_PLAN_E5","BPOS_S_TODO_3");
	'ADGroup'			= 'AG-O365-E5-Licensed-Users' ;
	'Type'				= 'Base'
	'BaseType'			= 'E5'
	'ADGroupTS'			= 'AG-o365_E5_users'; 
	}
'E5P' = @{
	'ServiceType'	 	= 'Collaboration Premium PowerBI';
	'AccountSku'		= 'swissport:ENTERPRISEPREMIUM';
	'PlansDisabled' 	=  @("PROJECTWORKMANAGEMENT","SWAY","RMS_S_ENTERPRISE","FLOW_O365_P3","POWERAPPS_O365_P3","TEAMS1","Deskless","MCOEV","THREAT_INTELLIGENCE","LOCKBOX_ENTERPRISE","ADALLOM_S_O365","EQUIVIO_ANALYTICS","EXCHANGE_ANALYTICS","FORMS_PLAN_E5","BPOS_S_TODO_3");
	'ADGroup'			= 'AG-O365-E5-Licensed-Users' ;
	'Type'				= 'Base'
	'BaseType'			= 'E5'
	}
'E5F' = @{
	'ServiceType'	 	= 'Collaboration Premium All';
	'AccountSku'		= 'swissport:ENTERPRISEPREMIUM';
	'PlansDisabled' 	=  @("PROJECTWORKMANAGEMENT","SWAY","RMS_S_ENTERPRISE","FLOW_O365_P3","POWERAPPS_O365_P3","TEAMS1","Deskless","THREAT_INTELLIGENCE","LOCKBOX_ENTERPRISE","ADALLOM_S_O365","EQUIVIO_ANALYTICS","EXCHANGE_ANALYTICS","FORMS_PLAN_E5","BPOS_S_TODO_3");
	'ADGroup'			= 'AG-O365-E5-Licensed-Users' ;
	'Type'				= 'Base'
	'BaseType'			= 'E5'
	}
'PSTN' = @{
	'ServiceType'		= 'PSTN Conferencing';
	'AccountSku'		= 'swissport:MCOMEETADV';
	'PlansDisabled'		=  @();
	'ADGroup'			= '';
	'Type'				= 'Addon'
    }
'ATP' = @{
	'ServiceType'		= 'Advanced Thread Protection';
	'AccountSku'		= 'swissport:ATP_ENTERPRISE';
	'PlansDisabled'		=  @();
	'ADGroup'			= '';
	'Type'				= 'Addon'
    }
'PBF' = @{
	'ServiceType'		= 'PowerBi Free';
	'AccountSku'		= 'swissport:POWER_BI_STANDARD';
	'PlansDisabled'		=  @();
	'ADGroup'			= '';
	'Type'				= 'Addon'
    }
'NONE' = @{
	'ServiceType'		= 'NONE';
	'AccountSku'		= 'NONE';
	'PlansDisabled'		=  @();
	'ADGroup'			= '';
	'Type'				= 'Addon'
	}
'POWERAPPS' = @{
	'ServiceType'		= 'PowerApps Service';
	'AccountSku'		= 'swissport:POWERAPPS_INDIVIDUAL_USER';
	'PlansDisabled'		=  @();
	'ADGroup'			= '';
	'Type'				= 'Base';
	'BaseType'			= '';
	'ADGroupTS'			= 'AG-o365_POWERAPP_users'; 
	'O365Group'			= 'ABZ.Function.puretest'; 
	}
}
$LicenseAlarmThresHolds = @{
'swissport:STANDARDPACK'=50;
'swissport:ENTERPRISEPACK'=25
'swissport:ENTERPRISEPREMIUM'=15
'swissport:ATP_ENTERPRISE'=50
'swissport:MCOMEETADV'=10
'swissport:DESKLESSPACK'=50
}
$Regions = @{
    'CANADA' = @('CA');
    'US' = @('US');
    'ASIA' = @('CN','JP','KR','KZ','SG');
    'DACH' = @('AT','CH','DE');
    'EUR' = @('BE','BG','CY','DK','ES','FI','FR','GR','HU','NL','PL','SK','PT','RU');
    'LATAM' = @('AN','AR','AW','BR','CL','CR','CW','DO','EC','MX','PE','SX','TT','VE','XX');
    'MEA' = @('AE','CM','DZ','GH','IL','KE','MA','NG','OM','SA','SN','TZ','ZA');
    'UKI' = @('GB','IE');
}
$CountryRegion = @{}
$Regions.keys | % {$cs=$Regions.Item($_);$key=$_;$cs | % {$CountryRegion.add($_,$key)}}
#$Licenses = $Licenses.GetEnumerator() | sort name
$RevLicenses = @{}
#$Licenses.keys | % {$sku=$Licenses.Item($_).AccountSku; if(!$RevLicenses.ContainsKey($sku)) {$RevLicenses.add("$sku","$_")}}
$Licenses.keys | % {$sku=$Licenses.Item($_).AccountSku;$key=$_; if($key -like 'E5*' -and $key.Length -gt 2) {} else {$RevLicenses.add("$sku","$key")}}
$RevLicensesService = @{}
$Licenses.keys | % {$st=$Licenses.Item($_).ServiceType; $RevLicensesService.add("$st","$_")}
# set directories
if (![string]::IsNullOrEmpty($overwrite)) {
    $FilePathRoot = $overwrite
} else {
    $FilePathRoot = $Environments.Item($Environment).Root
}
$InputPath = "$FilePathRoot\"+$Environments.Item($Environment).input
$outputPath = "$FilePathRoot\"+$Environments.Item($Environment).output
$logPath = "$FilePathRoot\"+$Environments.Item($Environment).log
$tempPath = "$FilePathRoot\"+$Environments.Item($Environment).tmp
$prefixCred = $Environments.Item($Environment).prefixCred
$pathDLL = $Environments.Item($Environment).pathDLL
$pathModule = $env:ScriptRoot+$Environments.Item($Environment).pathModule
$globalPath = $env:ScriptRoot+"\Global"

# AD Settings
$RootOUSPI = $Environments.Item($Environment).RootOUSPI
$RootOUNOAM = $Environments.Item($Environment).RootOUNOAM
$RootOUCORP = $Environments.Item($Environment).RootOUCORP
$WriteRootOUSPI = $Environments.Item($Environment).WriteRootOUSPI
$WriteRootOUCORP = $Environments.Item($Environment).WriteRootOUCORP
$WriteRootOUexceptionSPI = $Environments.Item($Environment).WriteRootOUExceptionSPI
$WriteRootOUexceptionCORP = $Environments.Item($Environment).WriteRootOUExceptionCORP
#AD O365 user group
$ADE1LicenseGroup = $Environments.Item($Environment).ADE1LicenseGroup
#Domain Controller to check for the User
$DCSPI = $Environments.Item($Environment).DCSPI
$DCNOAM = $Environments.Item($Environment).DCNOAM
$DCCORP = $Environments.Item($Environment).DCCORP
#Username of the Sync Admin in the Cloud
$AdminUserADSPI = $Environments.Item($Environment).AdminUserADSPI
$AdminUserADhashSPI = Get-Hash -env $Environment -user $AdminUserADSPI -path $globalPath
$AdminUserADpwdSPI = ConvertTo-SecureString $AdminUserADhashSPI -ErrorAction SilentlyContinue -ErrorVariable E
$credentialsADSPI = New-Object System.Management.Automation.PSCredential $AdminUserADSPI, $AdminUserADpwdSPI

$AdminUserADNOAM = $Environments.Item($Environment).AdminUserADNOAM
#$AdminUserADhashNOAM = $Environments.Item($Environment).AdminUserADhashNOAM
$AdminUserADhashNOAM = Get-Hash -env $Environment -user $AdminUserADNOAM -path $globalPath
$AdminUserADpwdNOAM = ConvertTo-SecureString $AdminUserADhashNOAM -ErrorAction SilentlyContinue -ErrorVariable E
$credentialsADNOAM = New-Object System.Management.Automation.PSCredential $AdminUserADNOAM, $AdminUserADpwdNOAM

$AdminUserADCORP = $Environments.Item($Environment).AdminUserADCORP
#$AdminUserADhashCORP = $Environments.Item($Environment).AdminUserADhashCORP
$AdminUserADhashCORP = Get-Hash -env $Environment -user $AdminUserADCORP -path $globalPath
$AdminUserADpwdCORP = ConvertTo-SecureString $AdminUserADhashCORP -ErrorAction SilentlyContinue -ErrorVariable E
$credentialsADCORP = New-Object System.Management.Automation.PSCredential $AdminUserADCORP, $AdminUserADpwdCORP

$OnPremAB = $Environments.Item($Environment).OnPremAB
$AddressListContainer = $Environments.Item($Environment).AddressListContainer

# special case NOAM check for responding DC
$DCNOAM =  $Environments.Item($Environment).DCNOAM
#Exchange Server to use for Mailbox creation
$ExchangeServer = $Environments.Item($Environment).ExchangeServer
#Remote Mail Domain in the Cloud
$RemoteDomain = $Environments.Item($Environment).RemoteDomain
# licesne and MPC attribute
$MigrationAttribute = $Environments.Item($Environment).MigrationAttribute
$LicenseAttribute = $Environments.Item($Environment).LicenseAttribute
$MPCcodeAttribute = $Environments.Item($Environment).MPCcodeAttribute
$daysUntilDelete = $Environments.Item($Environment).daysUntilDelete
$CitrixTSUsers = $Environments.Item($Environment).CitrixTSUsers
$CitrixTSGroups = $Environments.Item($Environment).CitrixTSGroups
#Usage Location for Office 365 Users
$UsageLocation = "CH"
$AdminUserAzure = $Environments.Item($Environment).AdminUserAzure
#$AdminUserAzurehash = $Environments.Item($Environment).AdminUserAzurehash
$AdminUserAzurehash = Get-Hash -env $Environment -user $AdminUserAzure -path $globalPath
$AdminUserAzurepwd = ConvertTo-SecureString $AdminUserAzurehash -ErrorAction SilentlyContinue -ErrorVariable E
$credentialsAzure = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $AdminUserAzure, $AdminUserAzurepwd
# MailAlertAddress
$MailAlertEmail = $Environments.Item($Environment).MailAlertEmail
$MailFrom = $Environments.Item($Environment).MailFrom
$MailHost = $Environments.Item($Environment).MailHost

$legacyDNPrefix = "/o=Swissport/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn="
# Filenames
$FNProcessAddLog = "ProcessAddCommits"
$FNProcessModifyLog = "ProcessModifyCommits"
$FNProcessDeleteLog = "ProcessDeleteCommits"
$FNProcessLMLog = "ProcessLicenseChanges"
$FNLicenseAssignmentScript = "LicenseAssignmentScript"
$FNLicenseAssignmentIgnoredUser = "LicenseAssignmentIgnoredUsers"
$FNLicensAlarm="LicenseAlarm"
$InputFilePrefixMSSQL="Dump-MSSQL"
$InputFilePrefixMSOL="Dump-MSOL"
$InputFilePrefixAD="Dump-AD"
$InputFilePrefixDBs="Dump-Oracle"
$InputFilePrefixDirX="Dump-DirX"
#
#
	if (!((test-path $FilePathRoot) -and (test-path $env:ScriptRoot))) {
		$userdomain = $env:userdomain
		write-warning "AD Environments and directory structure do not match:"
		write-warning ("Domain found:{0}, translated environment:{1}" -f $userdomain,$Environment)
		write-warning ("FilePathRoot:{0} exists:{1}" -f  $FilePathRoot,(test-path $FilePathRoot))
		write-warning ("ScriptRoot:{0} exists:{1}" -f  $env:ScriptRoot,(test-path $env:ScriptRoot))
		write-warning "exit script!"
		Break
	}