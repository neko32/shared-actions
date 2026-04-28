#!/bin/bash
# gh_copy_labels.bash
# neko32/tanunekolab_adr の issues label を指定したリポジトリにコピーする
#
# Usage: ./gh_copy_labels.bash <target_repo_name>
# Example: ./gh_copy_labels.bash nekokan_music

set -euo pipefail

SOURCE_REPO="neko32/tanunekolab_adr"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <target_repo_name>"
    echo "Example: $0 nekokan_music"
    exit 1
fi

TARGET_REPO="neko32/$1"

echo "コピー元: $SOURCE_REPO"
echo "コピー先: $TARGET_REPO"
echo ""

# コピー先リポジトリの存在確認
if ! gh repo view "$TARGET_REPO" > /dev/null 2>&1; then
    echo "エラー: リポジトリ '$TARGET_REPO' が見つかりません。リポジトリ名を確認してください。" >&2
    exit 1
fi

# コピー元のラベル一覧を取得
echo "ラベル一覧を取得中..."
labels_json=$(gh label list --repo "$SOURCE_REPO" --json name,color,description --limit 100)

total=$(echo "$labels_json" | jq 'length')
echo "${total} 件のラベルが見つかりました。"
echo ""

success=0
failed=0

while IFS= read -r label; do
    name=$(echo "$label" | jq -r '.name')
    color=$(echo "$label" | jq -r '.color')
    description=$(echo "$label" | jq -r '.description')

    printf "  [%s] をコピー中... " "$name"

    if gh label create "$name" \
        --color "$color" \
        --description "$description" \
        --repo "$TARGET_REPO" \
        --force > /dev/null 2>&1; then
        echo "OK"
        success=$((success + 1))
    else
        echo "失敗"
        failed=$((failed + 1))
    fi

done < <(echo "$labels_json" | jq -c '.[]')

echo ""
echo "完了: 成功 ${success} 件 / 失敗 ${failed} 件 (合計 ${total} 件)"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
