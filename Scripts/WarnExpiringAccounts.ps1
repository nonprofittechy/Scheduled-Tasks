#######################################
# WarnExpiringAccounts.ps1
# Purpose: send a warning message to the manager and user whose account will expire in the next 2 weeks
# End-user updates: see WarnExpiringAccounts.variables.ps1 and WarnExpiringAccounts.tmpl in this folder. 
# 				   The format to alter the messages or other settings should be easily worked out.


#######################################
# Setup
$cwd = split-path $myinvocation.mycommand.path
$htmlTemplateModulePath = join-path $cwd "HTMLTemplate.psm1"
$htmlTemplatePath = join-path $cwd "WarnExpiringAccounts.tmpl"
$variablesPath = Join-path $cwd  "WarnExpiringAccounts.variables.ps1"

import-module $htmlTemplateModulePath

. $variablesPath

#########################################
# functions
Function Send-Email ($to, $cc, $subject, $body) {
	send-mailmessage -subject $subject -bodyAsHTML $body -from $emailFrom  -to $to -cc $cc -smtpserver $emailServer
}

######################################
# action

$accounts = Search-ADAccount -AccountExpiring -TimeSpan $accountexpirationthreshold | get-aduser -properties mail,manager,accountexpirationdate

$template = New-HTMLTemplate(@{ filename = $htmlTemplatePath})


foreach ($account in $accounts) {
	$manager = get-aduser $account.manager -properties mail
	$dateString = get-date ($account.accountexpirationDate.addDays(-1)) -format D
	
	$subject = "The login account for " + $account.name + " will expire at the end of " + $dateString
	
	$template.param("USERNAME",$account.name)
	$template.param("CONTACTPERSON",$expiringaccount_contact)
	$template.param("EXPIRATIONDATE",$dateString)
	
	$emailBody = $template.output()
	$ccs = @($manager.mail) + $emailCC
	
	send-email -to $account.mail -cc $ccs -subject $subject -body $emailBody
}