#!/usr/bin/env bash
set -euo pipefail

cd /home/user/Proyectos/cdlan-portfolio

# 0) Local gate: aborta si algo falla
./scripts/preflight.sh

# 1) Commit + push solo si hay cambios
if ! git diff --quiet; then
  git add -A
  git commit -m "release: auto (local GREEN + remote checks)"
  git push origin main
else
  echo "Sin cambios locales."
fi

# 2) Esperar GitHub Pages y validar remoto
RID="$(gh run list --branch main --workflow 'Deploy to GitHub Pages' --limit 1 \
      --json databaseId -q '.[0].databaseId' || true)"
[ -n "${RID:-}" ] && gh run watch -i 5 "$RID" || true

TS="$(date +%s)"
URL="https://coderdeltalan.github.io/cdlan-portfolio/"
curl -fsS "${URL}?v=${TS}" -o /tmp/_remote.html
grep -Fq "Featured Projects"      /tmp/_remote.html
grep -Fq "type=public"            /tmp/_remote.html
grep -Fq "Yosvel — CoderDeltaLAN" /tmp/_remote.html
grep -Fq "application/ld+json"    /tmp/_remote.html
echo "Remote smoke OK ✅"

# 3) Lighthouse (tiene workflow_dispatch)
if gh workflow view .github/workflows/lighthouse.yml >/dev/null 2>&1; then
  gh workflow run .github/workflows/lighthouse.yml --ref main || true
  sleep 2
  LHR="$(gh run list --workflow '.github/workflows/lighthouse.yml' --branch main \
        --json databaseId -q '.[0].databaseId' || true)"
  [ -n "${LHR:-}" ] && gh run watch "$LHR" || true
fi

# 4) Resumen y aserción: no se permite 'failure'
echo "---- últimos 20 runs ----"
gh run list --limit 20 --json name,displayTitle,conclusion,createdAt \
  -q '.[] | [.createdAt, .name, .displayTitle, .conclusion] | @tsv'

FAILS="$(gh run list --limit 50 --json conclusion -q 'map(select(.conclusion=="failure")) | length')"
test "$FAILS" -eq 0 && echo "✅ REMOTE GREEN"
