$year = (Get-Date).Year
$distro_groups = Get-ADGroup -Filter "GroupCategory -eq 'Distribution' -and GroupScope -eq 'Universal'" -Properties *

ForEach ($distro_group in $distro_groups) {
    $name = $distro_group.CN
    $canonicalname = $distro_group.CanonicalName
    $created = $distro_group.Created
    $modified = $distro_group.Modified
    $year_modified = $modified.Year
    $members = $distro_group.Members
    $mail = $distro_group.mail
    $memberOf = $distro_group.MemberOf

    if ($year_modified -ne $year -and $members.count -eq 0 -and $memberOf.count -eq 0) {
        Write-Host "Name               : $name"
        Write-Host "Email Address      : $mail"
        Write-Host "Canonical Name     : $canonicalname"
        Write-Host "Date Created       : $created"
        Write-Host "Date Modified      : $modified"
        Write-Host "Members            : None"
        Write-Host "MemberOf           : None"
        Write-Host ""
    }
}
