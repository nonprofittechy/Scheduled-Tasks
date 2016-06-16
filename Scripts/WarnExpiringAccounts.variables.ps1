$accountexpirationthreshold = "8" # how many days in advance to search for expiring accounts. Remember, script runs weekly, so 8 should be minimum
$expiringaccount_contact = "<a href='mailto:_Personnel@DOMAIN.org?subject=Account%20expiration'>Personnel</a>"
$emailserver = "smtp.DOMAIN.org"
$emailFrom = "_Personnel@DOMAIN.org"
$emailCC = @("_Personnel@DOMAIN.org", "helpdesk@DOMAIN.org") # May be an array