<#PSScriptInfo
.VERSION 1.1.0
.GUID 1eb0572e-4b59-400a-9ade-bb623cba05be
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
    Version 1.1.0 (2024-06-13)
    - Add missing userPrincipalName property to user object when not present
#>

<#
.SYNOPSIS
    Routes EasyLife 365 webhook events to the appropriate child runbook based on the event type.

.DESCRIPTION
    This runbook is designed to be invoked by an Azure Automation webhook.
    It validates the webhook data object and routes the EasyLife 365 event to the appropriate child runbook based on the event type.

.PARAMETER WebhookData
    The webhook data object that is passed to the script by the webhook.

.EXTERNALHELP https://docs.easylife365.cloud/collab/integration/webhooks/overview
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [object]$WebhookData
)

#region [COMMON] GENERIC INPUT VALIDATION ------------------------------------------
if (-not $WebhookData) {
    Throw 'This runbook must be invoked with a webhook data object.'
}
if ($WebhookData -is [string]) {
    Write-Verbose "Converting webhook data from string to JSON object."
    $WebhookData = $WebhookData | ConvertFrom-Json
}
if ([string]::IsNullOrEmpty($WebhookData.WebhookName)) {
    Throw 'The webhook data object does not contain a webhook name.'
}
if ([string]::IsNullOrEmpty($WebhookData.RequestBody)) {
    Throw 'The webhook data object does not contain a request body.'
}
if (-not $WebhookData.RequestHeader -or $WebhookData.RequestHeader -isnot [PSCustomObject]) {
    Throw 'The webhook data object does not contain a request header.'
}

Write-Verbose "WebhookName: $($WebhookData.WebhookName)"
$WebhookData.RequestHeader.PSObject.Properties | ForEach-Object {
    Write-Verbose "RequestHeader Key: $($_.Name), Value: $($_.Value)"
}
Write-Verbose "RequestBody: $($WebhookData.RequestBody)"

if (
    [string]::IsNullOrEmpty($WebhookData.RequestHeader.'x-ms-request-id') -or
    $WebhookData.RequestHeader.'x-ms-request-id' -eq '00000000-0000-0000-0000-000000000000' -or
    $WebhookData.RequestHeader.'x-ms-request-id' -notmatch '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'
) {
    Throw 'The webhook data object request header does not contain a valid x-ms-request-id.'
}
if (
    [string]::IsNullOrEmpty($WebhookData.RequestHeader.Host) -or
    $WebhookData.RequestHeader.Host -notmatch '^[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]*\.azure-automation\.net$'
) {
    Throw 'The webhook data object request header does not contain a valid Host.'
}
if (
    [string]::IsNullOrEmpty($WebhookData.RequestHeader.traceparent) -or
    $WebhookData.RequestHeader.traceparent -notmatch '^[0-9a-fA-F]{2}-[0-9a-fA-F]{32}-[0-9a-fA-F]{16}-[0-9a-fA-F]{2}$'
) {
    Throw 'The webhook data object request header does not contain a valid traceparent.'
}
if (
    [string]::IsNullOrEmpty($WebhookData.RequestHeader.'Request-Id') -or
    $WebhookData.RequestHeader.'Request-Id' -notmatch '^\|([0-9a-fA-F]{32}(\.[0-9a-fA-F]{16})*)\.$'
) {
    Throw 'The webhook data object request header does not contain a valid Request-Id.'
}
else {
    $requestIdParts = $WebhookData.RequestHeader.'Request-Id'.Trim().Substring(1).Split('.')
    $requestIdHierarchy = $requestIdParts
}
if (
    [string]::IsNullOrEmpty($WebhookData.RequestHeader.'Request-Context')
) {
    Throw 'The webhook data object request header does not contain a valid Request-Context.'
}
else {
    $requestContext = @{}
    $requestContextParts = $WebhookData.RequestHeader.'Request-Context'.Split(';')
    foreach ($part in $requestContextParts) {
        $keyValue = $part.Split('=')
        if (
            $keyValue.Count -eq 2 -and
            -not [string]::IsNullOrEmpty($keyValue[0].Trim()) -and
            -not [string]::IsNullOrEmpty($keyValue[1].Trim())
        ) {
            $key = $keyValue[0].Trim()
            $value = $keyValue[1].Trim()
            if ($value -match '^cid-v1:(.+)$') {
                $value = $Matches[1]
                if ($value -notmatch '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$') {
                    Throw "The Request-Context contains an invalid correlation id for $key."
                }
            }
            $requestContext[$key] = $value
        }
    }
    if ($requestContext.Count -eq 0) {
        Throw 'The Request-Context does not contain any valid key-value pairs.'
    }
    foreach ($key in $requestContext.Keys) {
        Write-Verbose "Request-Context Key: $key, Value: $($requestContext[$key])"
    }
}

try {
    $data = $WebhookData.RequestBody | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Throw "The webhook data object request body is not a valid JSON object. Error: $($_.Exception.Message)"
}
#endregion ---------------------------------------------------------------------

#region [COMMON] IMPORT MODULES ------------------------------------------------
./Common_0000__Import-Module.ps1 -Modules @(
    @{ Name = 'PowerShellGet' } # Avoid any implicit module loading causing verbose output. Happens when calling child runbooks below.
)
#endregion ---------------------------------------------------------------------

#region [COMMON] OPEN CONNECTIONS: Microsoft Graph -----------------------------
./Common_0001__Connect-MgGraph.ps1 -Scopes @(
    # Read-only permissions

    # Write permissions

    # Other permissions
)
#endregion ---------------------------------------------------------------------

#region [COMMON] ENVIRONMENT ---------------------------------------------------
./Common_0002__Import-AzAutomationVariableToPSEnv.ps1 1> $null      # Implicitly connects to Azure Cloud
#endregion ---------------------------------------------------------------------

#region EasyLife 365 Event Routing ---------------------------------------------
$params = @{
    WebhookName = $WebhookData.WebhookName
    EventType   = $data.eventType
    Object      = $null
}

switch ($data.eventType) {
    'guestcreated' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.user -or
            -not $data.user.id -or
            -not $data.user.displayName
        ) {
            Throw 'The webhook data object request body does not contain a user object, or the user object is missing required properties.'
        }

        if (-not $data.user.userPrincipalName) {
            $userPrincipalName = (Invoke-MgGraphRequest -Method GET -Uri "/v1.0/users/$($data.user.id)").userPrincipalName
            if (-not $data.user.PSObject.Properties.Name -contains 'userPrincipalName') {
                $data.user | Add-Member -NotePropertyName 'userPrincipalName' -NotePropertyValue $userPrincipalName
            }
            else {
                $data.user.userPrincipalName = $userPrincipalName
            }
        }

        $params.Object = $data.user

        try {
            ./EL365_0100__Invoke-GuestCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-GuestCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 found."
        }
    }

    'guestmodified' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.user -or
            -not $data.user.id -or
            -not $data.user.displayName
        ) {
            Throw 'The webhook data object request body does not contain a user object, or the user object is missing required properties.'
        }

        if (-not $data.user.userPrincipalName) {
            $userPrincipalName = (Invoke-MgGraphRequest -Method GET -Uri "/v1.0/users/$($data.user.id)").userPrincipalName
            if (-not $data.user.PSObject.Properties.Name -contains 'userPrincipalName') {
                $data.user | Add-Member -NotePropertyName 'userPrincipalName' -NotePropertyValue $userPrincipalName
            }
            else {
                $data.user.userPrincipalName = $userPrincipalName
            }
        }

        $params.Object = $data.user

        try {
            ./EL365_0100__Invoke-GuestCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-GuestCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyGuestCreatedOrModifiedEvent.ps1 found."
        }
    }

    'teamcreated' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.team -or
            -not $data.team.id -or
            -not $data.team.displayName
        ) {
            Throw 'The webhook data object request body does not contain a team object, or the team object is missing required properties.'
        }
        $params.Object = $data.team

        try {
            ./EL365_0100__Invoke-TeamCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-TeamCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyTeamCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyTeamCreatedOrModifiedEvent.ps1 found."
        }
    }

    'teammodified' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.team -or
            -not $data.team.id -or
            -not $data.team.displayName
        ) {
            Throw 'The webhook data object request body does not contain a team object, or the team object is missing required properties.'
        }
        $params.Object = $data.team

        try {
            ./EL365_0100__Invoke-TeamCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-TeamCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyTeamCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyTeamCreatedOrModifiedEvent.ps1 found."
        }
    }

    'groupcreated' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.group -or
            -not $data.group.id -or
            -not $data.group.displayName
        ) {
            Throw 'The webhook data object request body does not contain a group object, or the group object is missing required properties.'
        }
        $params.Object = $data.group

        try {
            ./EL365_0100__Invoke-GroupCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-GroupCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyGroupCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyGroupCreatedOrModifiedEvent.ps1 found."
        }
    }

    'groupmodified' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.group -or
            -not $data.group.id -or
            -not $data.group.displayName
        ) {
            Throw 'The webhook data object request body does not contain a group object, or the group object is missing required properties.'
        }
        $params.Object = $data.group

        try {
            ./EL365_0100__Invoke-GroupCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-GroupCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MyGroupCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MyGroupCreatedOrModifiedEvent.ps1 found."
        }
    }

    'sharepointcreated' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.sharepoint -or
            -not $data.sharepoint.id -or
            -not $data.sharepoint.displayName
        ) {
            Throw 'The webhook data object request body does not contain a sharepoint object, or the sharepoint object is missing required properties.'
        }
        $params.Object = $data.sharepoint

        try {
            ./EL365_0100__Invoke-SharepointCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-SharepointCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MySharepointCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MySharepointCreatedOrModifiedEvent.ps1 found."
        }
    }

    'sharepointmodified' {
        Write-Verbose "Processing EasyLife 365 event: $($data.eventType)"
        if (
            -not $data.sharepoint -or
            -not $data.sharepoint.id -or
            -not $data.sharepoint.displayName
        ) {
            Throw 'The webhook data object request body does not contain a sharepoint object, or the sharepoint object is missing required properties.'
        }
        $params.Object = $data.sharepoint

        try {
            ./EL365_0100__Invoke-SharepointCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Throw "Failed to run EL365_0100__Invoke-SharepointCreatedOrModifiedEvent.ps1: $_"
        }

        try {
            ./EL365_0101__Invoke-MySharepointCreatedOrModifiedEvent.ps1 @params
        }
        catch {
            Write-Verbose "No custom runbook EL365_0101__Invoke-MySharepointCreatedOrModifiedEvent.ps1 found."
        }
    }

    default {
        Throw "EasyLife 365 event type '$($data.eventType)' is not supported by this runbook."
    }
}
#endregion ---------------------------------------------------------------------
