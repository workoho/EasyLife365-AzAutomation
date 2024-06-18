<#PSScriptInfo
.VERSION 1.2.0
.GUID 4e0cb66a-8ed8-4287-ae85-08e0bcb96850
.AUTHOR Julian Pawlowski
.COMPANYNAME Workoho GmbH
.COPYRIGHT © 2024 Workoho GmbH
.TAGS
.LICENSEURI https://github.com/workoho/EasyLife365-AzAutomation/blob/main/LICENSE.txt
.PROJECTURI https://github.com/workoho/EasyLife365-AzAutomation
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
    Version 1.2.0 (2024-06-18)
    - Fix EL365 event format
#>

<#
.SYNOPSIS
    Perform actions to guest users that were created or modified in EasyLife 365.

.DESCRIPTION
    This runbook is run by the EL365_2100__Invoke-Webhook-EventRouter.ps1 runbook when a guest user is created or modified in EasyLife 365.

    Note that this runbook is not intended to be run directly.

    In case you would like to have your own code running in the same way, you may copy this runbook under the name
    EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 and adjust the code to your needs.
    This will allow you to easily upgrade this runbook in the future without losing your customizations.

.PARAMETER WebhookName
    The name of the webhook that indirectly triggered this runbook.

.PARAMETER EventType
    The EasyLife 365 event type.

.PARAMETER Object
    The guest user object that was modified in EasyLife 365.

.NOTES
    In case you would like to have your own code running in the same way, you may copy this runbook under the name
    EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 and adjust the code to your needs. It will automatically be run by the WebhookEventRouter runbook.
    This will allow you to easily upgrade this runbook in the future without losing your customizations.

    Make sure to re-generate the GUID in the PSScriptInfo section of your custom runbook using the New-Guid cmdlet.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WebhookName,

    [Parameter(Mandatory = $true)]
    [string]$EventType,

    [Parameter(Mandatory = $true)]
    [object]$Object
)

if (-Not $PSCommandPath) { Write-Error 'This runbook is used by other runbooks and must not be run directly.' -ErrorAction Stop; exit }
Write-Verbose "---START of $((Get-Item $PSCommandPath).Name), $((Test-ScriptFileInfo $PSCommandPath | Select-Object -Property Version, Guid | & { process{$_.PSObject.Properties | & { process{$_.Name + ': ' + $_.Value} }} }) -join ', ') ---"
$StartupVariables = (Get-Variable | & { process { $_.Name } })      # Remember existing variables so we can cleanup ours at the end of the script

#region [COMMON] OPEN CONNECTIONS: Microsoft Graph -----------------------------
./Common_0001__Connect-MgGraph.ps1 -Scopes @(
    # Read-only permissions

    # Write permissions
    'Group.ReadWrite.All'

    # Other permissions
)
#endregion ---------------------------------------------------------------------

#region [COMMON] IMPORT MODULES ------------------------------------------------
./Common_0000__Import-Module.ps1 -Modules @(
    @{ Name = 'Microsoft.Graph.Groups'; MinimumVersion = '2.0'; MaximumVersion = '2.65535' }
)
#endregion ---------------------------------------------------------------------

#region [COMMON] ENVIRONMENT ---------------------------------------------------
./Common_0000__Convert-PSEnvToPSScriptVariable.ps1 -Variable @(
    @{
        sourceName    = "AV_EL365_GuestGroups"
        mapToVariable = 'GuestGroupsJson'
        defaultValue  = '{}'
        Regex         = '^.+$'
    }
) 1> $null

$GuestGroups = $null
if ($null -ne $GuestGroupsJson) {
    try {
        $GuestGroups = $GuestGroupsJson | ConvertFrom-Json
        Write-Verbose "Successfully converted the 'AV_EL365_GuestGroups' environment variable to a JSON object."
    }
    catch {
        Throw "Failed to convert the 'AV_EL365_GuestGroups' environment variable to a JSON object: $_"
    }
}
#endregion ---------------------------------------------------------------------

#region Process EasyLife 365 Event ---------------------------------------------
if ($Object.metadataExtension.additionalData) {
    $Object.metadataExtension.additionalData | & {
        process {
            $obj = $_
            Write-Verbose "Processing data from templateId $($obj.tId)"

            $obj.PSObject.Properties | & {
                process {
                    if ($_.Name -in @('@odata.type', 'id', 'extensionName', 'tId')) { return }
                    Write-Verbose "Processing property $($_.Name)"

                    #region Process group membership based on metadata ---------
                    $groupId = $null

                    if ($_.Name -match '^(?:el-)?grp-([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})$') {
                        $groupId = $Matches[1]
                        Write-Verbose "Found group ID $groupId in property name."
                    }
                    elseif (
                        $null -ne $GuestGroups -and
                        $GuestGroups.PSObject.Properties.Name -contains $_.Name
                    ) {
                        if ($GuestGroups.$($_.Name) -match '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$') {
                            $groupId = $GuestGroups.$($_.Name)
                            Write-Verbose "Found group ID $groupId in mapping table."
                        }
                        else {
                            try {
                                $groupId = Get-MgGroup -Filter "displayName eq '$($GuestGroups.$($_.Name))'" -ErrorAction Stop | Select-Object -ExpandProperty Id
                                if ($groupId.Count -ne 1) {
                                    Throw "Invalid group name in mapping table for property $($_.Name): $($GuestGroups.$($_.Name))"
                                }
                            }
                            catch {
                                Write-Warning "Failed to retrieve group $($GuestGroups.$($_.Name)): $_"
                                return
                            }
                            $groupId = $groupId[0]
                            Write-Verbose "Found group ID $groupId in mapping table."
                        }
                    }

                    if ($groupId) {
                        $params = @{
                            Method = 'POST'
                            Uri = "/v1.0/users/$($Object.id)/checkMemberGroups"
                            Body = @{
                                groupIds = @($groupId)
                            }
                        }
                        $IsGroupMember = (Invoke-MgGraphRequest @params).Value -contains $groupId

                        if ($_.Value) {
                            if ($IsGroupMember) { return }
                            Write-Verbose "Adding user '$($Object.userPrincipalName)' ($($Object.id)) to group $groupId."
                            try {
                                $null = New-MgGroupMember -GroupId $groupId -DirectoryObjectId $Object.id -ErrorAction stop
                            }
                            catch {
                                Write-Warning "Failed to add user $($Object.userPrincipalName) to group ${groupId}: $_"
                                return
                            }
                            Write-Output "User $($Object.userPrincipalName) has been added to group $groupId."
                        }
                        else {
                            if (-Not $IsGroupMember) { return }
                            Write-Verbose "Removing user '$($Object.userPrincipalName)' ($($Object.id)) from group $groupId."
                            try {
                                $null = Remove-MgGroupMemberDirectoryObjectByRef -GroupId $groupId -DirectoryObjectId $Object.id -ErrorAction stop
                            }
                            catch {
                                Write-Warning "Failed to remove user $($Object.userPrincipalName) from group ${groupId}: $_"
                                return
                            }
                            Write-Output "User $($Object.userPrincipalName) has been removed from group $groupId."
                        }
                    }
                    #endregion -------------------------------------------------
                }
            }
        }
    }
}
#endregion ---------------------------------------------------------------------

Get-Variable | Where-Object { $StartupVariables -notcontains $_.Name } | & { process { Remove-Variable -Scope 0 -Name $_.Name -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Verbose:$false -Debug:$false -Confirm:$false -WhatIf:$false } }        # Delete variables created in this script to free up memory for tiny Azure Automation sandbox
Write-Verbose "-----END of $((Get-Item $PSCommandPath).Name) ---"
