# Start transcript
#Start-Transcript -Path C:\Users\Administrator\Documents\Lab3\git\MIS517\Lab3_AD_Config\import_group_users.log -Append

# Import AD Module
Import-Module ActiveDirectory

# Import the data from CSV file and assign it to variable
$GroupUsers = Import-Csv "C:\Users\Administrator\Documents\Lab3\git\MIS517\Lab3_AD_Config\OrgChartDataGroupUsers.csv"


foreach ($GroupUser in $GroupUsers) {
    # Retrieve UPN
    $UDN = $GroupUser.DN
    $Group = $GroupUser.GroupDN

    # Retrieve UPN related SamAccountName
    $ADUser = Get-ADUser -Filter "DistinguishedName -eq '$UDN'" | Select-Object SamAccountName

    # User from CSV not in AD
    if ($ADUser -eq $null) {
        Write-Host "$UDN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Retrieve AD user group membership
        $ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName | Select-Object Name

        # User already member of group
        if ($ExistingGroups.Name -eq $Group) {
            Write-Host "$UDN already exists in $Group" -ForeGroundColor Yellow
        }
        else {
            # Add user to group
#            Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -WhatIf
            Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -Confirm
#            Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName 
            Write-Host "Added $UDN to $Group" -ForeGroundColor Green
        }
    }
}
#Stop-Transcript