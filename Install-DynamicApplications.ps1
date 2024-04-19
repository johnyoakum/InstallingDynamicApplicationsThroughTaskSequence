<#
    .SYNOPSIS
    Get latest verion of the applications for dynamically installing during Task Sequence

    .DESCRIPTION
    This script will reach out to the ConfigMgr Admin Service and retrieve all the available applications and then based on the applications you want to install, will dynamically set
    a task sequence variable to install the latest version.

    You will need to change lines 28 - 31 to suite your environment
    You will also need to modify line 43 for the applications you wish to install using the format of 'Google Chrome*'. Don't forget to include the * otherwise it won't pull the data
    correctly.

    In order to leverage this, on task sequences, add a step prior to the "Install Application" action called "Run PowerShell Script", copy and paste this code in the powershell 
    area and set the policy to bypass. On the "Install Application" action, change to using a Task Sequence Variable and enter "XApplications"

    This is currently set in debug mode, you will take it out of debug mode by changing Line 28 to $false
    .EXAMPLE
    .\Install-DynamicApplications.ps1

    .NOTES
    Version:        1.0
    Author:         John Yoakum, Recast Software
    Creation Date:  04/19/2024
    Purpose/Change: Initial script development

#>
# Script Variables
$Script:Debug = $True # Be sure to set this to False in production environment
$UserPassword = 'PASSWORD' # use service account password
$UserName = 'domain\username' # use domain\serviceaccount
$SiteServerFQDN = 'FQDN of site server' # this is in the form of servername.domain.com

# Create the Array for storing all the applications
$Applications = [System.Collections.ArrayList]::new()

# Get all Applications in ConfifMgr
$Password = ConvertTo-SecureString “$UserPassword” -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential (“$UserName”, $Password)
$AllItems = (Invoke-RestMethod -Method 'Get' -Uri "https://$SiteServerFQDN/AdminService/wmi/SMS_Application" -Credential $Credential).Value | Select-Object -Property LocalizedDisplayName,SoftwareVersion
$AllSortedItems = $AllItems | Sort-Object -Property LocalizedDisplayName,SoftwareVersion

# Enter in the applications you wish to install
$ApplicationsToInstall = 'Google Chrome*','Microsoft Visual Studio Code*','Recast Software Recast Agent*'

# Put together a single list of all the current applications to install
ForEach ( $Application in $ApplicationsToInstall ) {
    $ApplicationName = $AllSortedItems | Where-Object {$_.LocalizedDisplayName -like "$Application"} | Select-Object -Last 1
    $CurrentApp = New-Object PSObject -prop @{
        Name=$ApplicationName.LocalizedDisplayName
        }
        [void]$Applications.Add($CurrentApp)
}

# Set the Task Sequence Variable to those Applications
If (!$Script:Debug) { $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment }
$Count = 1
$AppId = @()
ForEach ( $App in $($Applications).Name ) {
    #Add Code to add apps
    $Id = "{0:D2}" -f $Count
    $AppId = "XApplications$Id" 
    If (!$Script:Debug) { $tsenv.Value($AppId) = $($App.Name) } else { Write-Host $App }
    $Count++
}
