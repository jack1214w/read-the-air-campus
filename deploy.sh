#!/bin/bash
# ============================================================
# 讀空氣校園系列 — 一鍵更新部署腳本
# 用法：在終端機輸入
#   ~/Desktop/CC工作區/Code專屬/read-the-air-campus/deploy.sh
# 它會自動：
#   1. 把最新的遊戲檔（read-the-air-campus.html）包成完整網頁 → index.html
#   2. 提交（commit）
#   3. 推送（push）到 GitHub
#   4. GitHub Pages 約 1 分鐘後自動重新部署
# ============================================================
set -e
cd "$(dirname "$0")"
SRC="../read-the-air-campus.html"

# 1) 產生 index.html
#    遊戲檔是 Claude Artifact 格式（沒有 <html>/<head>/<body>），
#    這裡補上完整網頁外殼：</style> 以前放進 <head>，其餘放進 <body>。
if [ -f "$SRC" ]; then
  {
    cat <<'HEAD'
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<style>
:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
body{margin:0;font-size:14px;font-family:system-ui,sans-serif}
img{max-width:100%}
[hidden]{display:none!important}
</style>
HEAD
    awk 'f{next} {print} /<\/style>/{f=1}' "$SRC"
    echo '</head>'
    echo '<body>'
    awk 'f{print} /<\/style>/{f=1}' "$SRC"
    echo '</body>'
    echo '</html>'
  } > index.html
  echo "✔ 已產生最新的 index.html"
else
  echo "⚠ 找不到 $SRC，跳過產生（直接部署現有內容）"
fi

# 2) 檢查是否有任何變更（含新增檔案）
if [ -z "$(git status --porcelain)" ]; then
  echo "沒有變更，線上版已是最新，不需要部署。"
  exit 0
fi

# 3) 提交並推送
git add -A
git commit -m "更新遊戲 $(date '+%Y-%m-%d %H:%M')"
git push -u origin main

echo ""
echo "✅ 推送完成！GitHub Pages 約 1 分鐘後自動更新："
echo "   https://jack1214w.github.io/read-the-air-campus/"
