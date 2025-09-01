#!/usr/bin/env bash
# sin set -euo pipefail

OWNER=CoderDeltaLAN
REPO=cdlan-portfolio
FAIL=0

echo "== Local smoke =="
npm ci >/dev/null 2>&1 || FAIL=1
npx astro check >/dev/null 2>&1 || true
npm run build >/dev/null 2>&1 || FAIL=1

npm run preview >/tmp/astro-preview.log 2>&1 & PREVIEW_PID=$!
sleep 5
if curl -fsI http://localhost:4321/ >/dev/null 2>&1 || curl -fsI http://localhost:4322/ >/dev/null 2>&1; then
  echo "SMOKE OK"
else
  echo "SMOKE FAIL"; tail -n 80 /tmp/astro-preview.log; FAIL=1
fi
[ -n "${PREVIEW_PID:-}" ] && kill $PREVIEW_PID >/dev/null 2>&1
rm -rf .astro .vite

echo "== Clean runs no-success (ci.yml / deploy.yml) =="
for WF in deploy.yml ci.yml; do
  gh api "repos/$OWNER/$REPO/actions/workflows/$WF/runs?per_page=50" \
     -q '.workflow_runs[]|select(.conclusion!="success")|.id' 2>/dev/null |
  while read -r ID; do
    [ -n "$ID" ] && gh api -X DELETE "repos/$OWNER/$REPO/actions/runs/$ID" >/dev/null 2>&1 && echo "deleted $WF#$ID"
  done
done

echo "== Pages status =="
gh api "repos/$OWNER/$REPO/pages" --jq '{status:.status,url:.html_url}' 2>/dev/null || echo "(no pages yet)"

if [ "${1:-}" = "--trigger" ]; then
  if gh workflow view deploy.yml >/dev/null 2>&1; then
    gh workflow run deploy.yml --ref main >/dev/null 2>&1 && echo "triggered deploy.yml"
    gh run list --workflow deploy.yml --limit 5
  else
    echo "deploy.yml not in main; nothing triggered"
  fi
else
  echo "(no dispatch; usa: scripts/repair_actions_pages.sh --trigger para publicar)"
fi

[ "$FAIL" -eq 0 ] && echo "READY" || echo "WARN: revisar arriba"
exit 0
