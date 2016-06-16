
###########################################
# Report on newly created accounts in AD
# run this report with scheduled tasks

#######################################
# Setup
$cwd = split-path $myinvocation.mycommand.path
$variablesPath = Join-path $cwd  "ReportNewADAccounts.variables.ps1"

$htmlTemplateModulePath = join-path $cwd "HTMLTemplate.psm1"
$htmlTemplatePath = join-path $cwd "ReportNewADAccounts.tmpl"

import-module $htmlTemplateModulePath
. $variablesPath

$groupOUs = @()
foreach ($group in $sensitiveGroups) {
	$groupOUS += (get-adgroup $group).DistinguishedName
}

#########################################
# functions
Function Send-Email ($to, $subject, $body) {
	send-mailmessage -subject $subject -bodyAsHTML $body -from $emailFrom  -to $to -smtpserver $emailServer
}

function get-warnings ($account) {
	$warnings = ""
	foreach ($group in $account.memberOf) {
		if ($groupOUS -contains $group) {
			$friendlyGroup = (get-adgroup $group).name
			$warnings += ("<p>Warning: user in sensitive group, " + $friendlyGroup + "</p>")
		}
	}
	
	foreach ($property in $sensitiveProperties.getEnumerator() ) {
		if ($account.get_Item($property.name) -eq $property.value) {
			$warnings += ("<p>Warning: property " + $property.name + " is set to sensitive value, " + $property.value)
		}
	}
	
	return $warnings
}

######################################
# action

$currentDate = get-date
$date = (get-date).addDays(-1*$timeSpan)
$domain = get-addomain

$accounts = get-aduser -filter {whenCreated -gt $date} -properties ($extraProperties+@("displayName","department","whencreated","memberof"))
$template = New-HTMLTemplate(@{ filename = $htmlTemplatePath})
$template.param("CURRENTDATE",$currentDate)
$template.param("STARTDATE",$date)
$template.param("DOMAINDNSROOT",$domain.DNSRoot)

$tmpl_accounts = @()

foreach ($account in $accounts) {
	$warnings = get-warnings -account $account
	$tmpl_account = @{"SAMACCOUNTNAME" = $account.samAccountName; 
					"NAME"=$account.displayName;  
					"DEPARTMENT" = $account.department; 
					"WARNINGS" = $warnings}
	
	$tmpl_accounts += $tmpl_account
}

$template.param("USERS",$tmpl_accounts)

$emailBody = $template.output()
$subject = ( "AD New User report: " + $accounts.length + " new users created in the last " + $timeSpan + " days run at " + $currentDate)

send-email -to $emailTo -subject $subject -body $emailBody