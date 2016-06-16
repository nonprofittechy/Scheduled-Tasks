$timeSpan = 8 # Use a positive whole-number integer -- this is the period we will report on. Best to set to 1 day more often than script will run
$emailFrom = "helpdesk@ORGANIZATION.org"
$emailTo = "helpdesk@ORGANIZATION.org" # may be an array
$emailServer = "smtp.ORGANIZATION.org"
$extraProperties = "manager","emailAddress","AccountExpirationDate","passwordneverexpires" # make sure includes any "sensitive" properties below
$sensitiveGroups = @("Helpdesk Staff","Domain Admins","IT","IT-Admins","User Account Creation","Management","Configuration Manager Administrators","Configuration Manager Limited Administrators") #should be an array-check for membership in these groups
$sensitiveProperties = @{"PasswordNeverExpires" = "True"}