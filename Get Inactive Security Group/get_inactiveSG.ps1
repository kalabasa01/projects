$year = (Get-Date).Year
$sec_groups = Get-ADGroup -Filter "GroupCategory -eq 'Security' -and GroupScope -eq 'Global'" -Properties *

ForEach ($sec_group in $sec_groups) {
    $name = $sec_group.CN
    $canonicalname = $sec_group.CanonicalName
    $created = $sec_group.Created
    $modified = $sec_group.Modified
    $year_modified = $modified.Year
    $members = $sec_group.Members
    $memberOf = $sec_group.MemberOf

    if ($year_modified -ne $year -and $canonicalname -like "*/OSS SEC GROUP/*") {
        if($members.count -eq 0 -and $memberOf.count -eq 0){
            Write-Host "Name               : $name"
            Write-Host "Canonical Name     : $canonicalname"
            Write-Host "Date Created       : $created"
            Write-Host "Date Modified      : $modified"
            Write-Host "Member Of          : None"
            Write-Host "Members            : None"
            Write-Host ""
        } 
    }
}
