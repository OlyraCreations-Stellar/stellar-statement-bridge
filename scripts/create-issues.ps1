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

$issueNumber = 0
$issues = foreach ($match in $issueMatches) {
    $issueNumber++
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
        Blocked = ($issueNumber -gt 3)
        Labels = @(
            "type: $type",
            "complexity: $complexity"
            if ($issueNumber -gt 3) { 'status: blocked' }
        )
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
    @{ Name = 'type: documentation'; Color = '0075ca'; Description = 'User or developer documentation.' },
    @{ Name = 'status: blocked'; Color = 'ededed'; Description = 'Wait for the maintainer go decision after discovery issues 1–3.' }
)

$availableLabels = @(& gh label list --repo $Repository --limit 100 --json name --jq '.[].name')
if ($LASTEXITCODE -ne 0) {
    throw "Could not list labels in $Repository."
}

foreach ($definition in $labelDefinitions) {
    if ($definition.Name -notin $availableLabels) {
        & gh label create $definition.Name --color $definition.Color --description $definition.Description --repo $Repository
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create required label '$($definition.Name)' in $Repository."
        }
        $availableLabels += $definition.Name
    }
}

foreach ($definition in $labelDefinitions) {
    if ($definition.Name -notin $availableLabels) {
        throw "Required label '$($definition.Name)' is unavailable in $Repository."
    }
}

$existingRows = @(& gh issue list --repo $Repository --state all --limit 100 --json number,title --jq '.[]|[.number,.title]|@tsv')
if ($LASTEXITCODE -ne 0) {
    throw "Could not list issues in $Repository."
}
$existingIssues = foreach ($row in $existingRows) {
    $parts = $row -split "`t", 2
    [pscustomobject]@{
        Number = [int]$parts[0]
        Title = $parts[1]
    }
}
$blockedIssueNumbers = @(& gh issue list --repo $Repository --state all --limit 100 --label 'status: blocked' --json number --jq '.[].number')
if ($LASTEXITCODE -ne 0) {
    throw "Could not list blocked issues in $Repository."
}

foreach ($issue in $issues) {
    $existingIssue = $existingIssues |
        Where-Object { $_.Title -eq $issue.Title } |
        Sort-Object Number |
        Select-Object -First 1
    if ($existingIssue) {
        if ($issue.Blocked -and $existingIssue.Number -notin $blockedIssueNumbers) {
            & gh issue edit $existingIssue.Number --repo $Repository --add-label 'status: blocked'
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to mark existing issue '$($issue.Title)' as blocked."
            }
        }
        Write-Output "Verified existing issue: $($issue.Title)"
        continue
    }

    $createArguments = @('issue', 'create', '--repo', $Repository, '--title', $issue.Title, '--body', $issue.Body)
    foreach ($label in $issue.Labels) {
        $createArguments += @('--label', $label)
    }
    & gh @createArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create issue '$($issue.Title)' in $Repository."
    }
}

Write-Output "Created or verified all 20 planned issues in $Repository."
