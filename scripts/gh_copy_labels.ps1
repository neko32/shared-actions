# gh_copy_labels.ps1
# neko32/tanunekolab_adr の issues label を指定したリポジトリにコピーする
#
# Usage: .\gh_copy_labels.ps1 <target_repo_name>
# Example: .\gh_copy_labels.ps1 nekokan_music

param(
    [Parameter(Mandatory = $true, HelpMessage = "コピー先のリポジトリ名 (neko32/<name> の <name> 部分)")]
    [string]$TargetRepo
)

$SOURCE_REPO = "neko32/tanunekolab_adr"
$TARGET_REPO = "neko32/$TargetRepo"

Write-Host "コピー元: $SOURCE_REPO"
Write-Host "コピー先: $TARGET_REPO"
Write-Host ""

# コピー先リポジトリの存在確認
$repoCheck = gh repo view $TARGET_REPO 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "リポジトリ '$TARGET_REPO' が見つかりません。リポジトリ名を確認してください。"
    exit 1
}

# コピー元のラベル一覧を取得
Write-Host "ラベル一覧を取得中..."
$labelsJson = gh label list --repo $SOURCE_REPO --json name,color,description --limit 100 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "ラベル一覧の取得に失敗しました: $labelsJson"
    exit 1
}

$labels = $labelsJson | ConvertFrom-Json
$total = $labels.Count
Write-Host "$total 件のラベルが見つかりました。"
Write-Host ""

$success = 0
$failed = 0

foreach ($label in $labels) {
    $name = $label.name
    $color = $label.color
    $description = $label.description

    Write-Host -NoNewline "  [$name] をコピー中... "

    $result = gh label create "$name" `
        --color "$color" `
        --description "$description" `
        --repo "$TARGET_REPO" `
        --force 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK"
        $success++
    } else {
        Write-Host "失敗: $result"
        $failed++
    }
}

Write-Host ""
Write-Host "完了: 成功 $success 件 / 失敗 $failed 件 (合計 $total 件)"

if ($failed -gt 0) {
    exit 1
}
