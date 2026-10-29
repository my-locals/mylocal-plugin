#!/usr/bin/env bash
# 4개 플러그인 메타데이터 파일의 "version" 값을 일괄 변경한다.
# 사용법: scripts/bump-version.sh 0.2.0
set -euo pipefail

NEW_VERSION="${1:?사용법: scripts/bump-version.sh <new-version>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILES=(
  "$ROOT/.claude-plugin/plugin.json"
  "$ROOT/.claude-plugin/marketplace.json"
  "$ROOT/.codex-plugin/plugin.json"
  "$ROOT/gemini-extension.json"
)

for f in "${FILES[@]}"; do
  sed -i '' -E 's/"version": *"[^"]+"/"version": "'"$NEW_VERSION"'"/' "$f"
  echo "updated: $f"
done

echo
echo "변경 결과:"
grep -n '"version"' "${FILES[@]}"
