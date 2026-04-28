# gh_copy_labels.ps1
# Copy issue labels from neko32/tanunekolab_adr to a specified repository
#
# Usage: .\gh_copy_labels.ps1 <target_repo_name>
# Example: .\gh_copy_labels.ps1 nekokan_music

param(
    [Parameter(Mandatory = $true, HelpMessage = "Target repository name (the <name> part of neko32/<name>)")]
    [string]$TargetRepo
)

$SOURCE_REPO = "neko32/tanunekolab_adr"
$TARGET_REPO = "neko32/$TargetRepo"

Write-Host "Source: $SOURCE_REPO"
Write-Host "Target: $TARGET_REPO"
Write-Host ""

# Verify target repository exists
$repoCheck = gh repo view $TARGET_REPO
if ($LASTEXITCODE -ne 0) {
    Write-Error "Repository '$TARGET_REPO' not found. Please check the repository name."
    exit 1
}

# Fetch label list from source repository
Write-Host "Fetching labels..."
$labelsJson = gh label list --repo $SOURCE_REPO --json name,color,description --limit 100
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to fetch labels: $labelsJson"
    exit 1
}

$labels = $labelsJson | ConvertFrom-Json
$total = $labels.Count
Write-Host "Found $total label(s)."
Write-Host ""

$success = 0
$failed = 0

foreach ($label in $labels) {
    $name = $label.name
    $color = $label.color
    $description = $label.description

    Write-Host -NoNewline "  Copying [$name]... "

    gh label create "$name" `
        --color "$color" `
        --description "$description" `
        --repo "$TARGET_REPO" `
        --force | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK"
        $success++
    } else {
        Write-Host "FAILED"
        $failed++
    }
}

Write-Host ""
Write-Host "Done: $success succeeded / $failed failed (total $total)"

if ($failed -gt 0) {
    exit 1
}
