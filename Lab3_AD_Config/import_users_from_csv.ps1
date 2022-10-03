#Enter a path to your import CSV file
$ADUsers = Import-csv C:\Users\Administrator\Documents\Lab3\git\MIS517\OrgChartDataUser.csv


foreach ($User in $ADUsers)
{
       $SamAccountName  = $User.SamAccountName
       $tmp_pwd         = $User.tmp_pwd
       $GivenName       = $User.GivenName
       $Surname         = $User.Surname
       $Department      = $User.department_ou
       $Title           = $User.Title
       $Company         = "Fortune Automotive Group"
       $OU              = $User.ou_string
       $manager         = $User.Manager

       if($manager) 
       {
            $managerADUser   = (Get-ADUser -Filter "Name -eq '$manager'" -SearchBase "DC=fortuneautomotive,DC=com").distinguishedname
       }
       else 
       {
            $managerADUser = ""
       }

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $SamAccountName})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $SamAccountName has already exist in Active Directory."
       }
       else
       {
            #If a user does not exist then create a new user account
            Write-Warning "ready to create $SamAccountName"

            $props = @{
                Name = "$GivenName $Surname" 
                SamAccountName = "$SamAccountName" 
                UserPrincipalName = "$SamAccountName@fortuneautomotive.com" 
                GivenName = "$GivenName" 
                Surname = "$Surname" 
                DisplayName = "$Surname, $GivenName" 
                Title = "$Title" 
                Enabled = $True 
                ChangePasswordAtLogon = $True 
                Department = "$Department" 
                Company = "$Company" 
                Path = "$OU" 
                AccountPassword = ConvertTo-SecureString $tmp_pwd -AsPlainText -Force 
            }
            if($managerADUser)
            {
                $props.Add("Manager", "$managerADUser")
            }

            Write-Host ($props |  Out-String)

            
#            New-ADUser -WhatIf @props -PassThru
            New-ADUser -Confirm @props -PassThru
#            New-ADUser @props -PassThru

       }
}