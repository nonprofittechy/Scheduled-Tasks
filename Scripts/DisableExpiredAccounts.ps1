$users = Search-ADAccount -usersonly -AccountExpired 

$users | %{ set-aduser $_ -enabled:$false; move-adobject $_ -targetpath "OU=Disabled,OU=_Domain_Users,DC=gbls,DC=local" }