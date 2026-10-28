param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$backlogPath = Join-Path $PSScriptRoot '..\docs\ISSUE_BACKLOG_DRAFT.md'
$backlog = Get-Content -LiteralPath $backlogPath -Raw
$issueMatches = [regex]::Matches(
    $backlog,
    '(?ms)^##\s+\d+\.\s+`([^`]+)`\s*\r?\n(.*?)(?=^##\s+\d+\.|\z)'
)

if ($issueMatches.Count -ne 20) {
    throw "Expected exactly 20 draft issues; found $($issueMatches.Count)."
}

$issues = foreach ($match in $issueMatches) {
    $title = $match.Groups[1].Value.Trim()
    $section = $match.Groups[2].Value.Trim()
    $meta = [regex]::Match($section, '\*\*Type/complexity:\*\*\s*([^/\r\n]+)/\s*([^\r\n]+)')
    $summary = [regex]::Match($section, '(?s)\*\*Summary:\*\*\s*(.*?)(?=\r?\n\*\*Acceptance Criteria:\*\*)')
    $criteria = [regex]::Match($section, '(?s)\*\*Acceptance Criteria:\*\*\s*(.*?)(?=\r?\n\*\*Tech Stack:\*\*)')
    $stack = [regex]::Match($section, '\*\*Tech Stack:\*\*\s*(.*)')

    if (-not $meta.Success -or -not $summary.Success -or -not $criteria.Success -or -not $stack.Success) {
        throw "Issue draft '$title' does not contain all required fields."
    }

    $type = $meta.Groups[1].Value.Trim().ToLowerInvariant()
    $complexity = $meta.Groups[2].Value.Trim().ToLowerInvariant()
    if ($complexity -notin @('trivial', 'medium', 'high')) {
        throw "Issue draft '$title' has unsupported complexity '$complexity'."
    }

    $body = @"
## Summary
$($summary.Groups[1].Value.Trim())

## Acceptance Criteria
$($criteria.Groups[1].Value.Trim())

## Tech Stack
$($stack.Groups[1].Value.Trim())

Please reference this issue in the pull request and use `Closes #<issue-number>` when it is fully resolved.
"@

    [pscustomobject]@{
        Title = $title
        Body = $body.Trim()
        Labels = @("type: $type", "complexity: $complexity")
    }
}

if ($DryRun) {
    $issues | ForEach-Object { $_.Title }
    return
}

$labelDefinitions = @(
    @{ Name = 'complexity: trivial'; Color = '0e8a16'; Description = 'Small, narrowly scoped contributor task.' },
    @{ Name = 'complexity: medium'; Color = 'fbca04'; Description = 'Standard feature or involved fix.' },
    @{ Name = 'complexity: high'; Color = 'b60205'; Description = 'Complex integration, security, or architectural task.' },
    @{ Name = 'type: research'; Color = '5319e7'; Description = 'Evidence gathering or compatibility research.' },
    @{ Name = 'type: feature'; Color = '1d76db'; Description = 'Product functionality.' },
    @{ Name = 'type: security'; Color = 'd93f0b'; Description = 'Security or permission work.' },
    @{ Name = 'type: testing'; Color = 'bfdadc'; Description = 'Test coverage and verification.' },
    @{ Name = 'type: maintenance'; Color = 'c5def5'; Description = 'CI and repository maintenance.' },
    @{ Name = 'type: documentation'; Color = '0075ca'; Description = 'User or developer documentation.' }
)

foreach ($definition in $labelDefinitions) {
    & gh label create $definition.Name --color $definition.Color --description $definition.Description --repo $Repository 2>$null | Out-Null
}

$availableLabels = @(& gh label list --repo $Repository --limit 100 --json name --jq '.[].name')
foreach ($definition in $labelDefinitions) {
    if ($definition.Name -notin $availableLabels) {
        throw "Required label '$($definition.Name)' is unavailable in $Repository."
    }
}

$existingTitles = @(& gh issue list --repo $Repository --state all --limit 100 --json title --jq '.[].title')
foreach ($issue in $issues) {
    if ($issue.Title -in $existingTitles) {
        Write-Output "Skipping existing issue: $($issue.Title)"
        continue
    }

    & gh issue create --repo $Repository --title $issue.Title --body $issue.Body --label $issue.Labels[0] --label $issue.Labels[1]
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create issue '$($issue.Title)' in $Repository."
    }
}

Write-Output "Created or verified all 20 planned issues in $Repository."
