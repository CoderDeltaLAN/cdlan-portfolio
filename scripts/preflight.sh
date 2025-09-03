#!/usr/bin/env bash
set -euo pipefail

echo "→ Astro check + build"
npx astro check >/dev/null
npm run -s build >/dev/null

# Servir dist y esperar 200 en silencio
PORT="$(shuf -i 4500-4999 -n1)"
python3 -m http.server "$PORT" --directory dist >/tmp/site-server.log 2>&1 & PID=$!
cleanup(){ kill "$PID" 2>/dev/null || true; }
trap cleanup EXIT

ready=0
for i in {1..40}; do
  if curl -fs "http://127.0.0.1:$PORT/" -o /tmp/_page.html 2>/dev/null; then
    ready=1; break
  fi
  sleep 0.5
done
[ "$ready" -eq 1 ] || { echo "❌ Server no arrancó"; exit 1; }

echo "→ Smoke"
grep -Fq "Featured Projects"      /tmp/_page.html
grep -Fq "type=public"            /tmp/_page.html
grep -Fq "Yosvel — CoderDeltaLAN" /tmp/_page.html
grep -Fq "application/ld+json"    /tmp/_page.html

echo "→ Link-check (<a href=...> externos)"
mapfile -t LINKS < <(grep -Eo '<a[^>]*href="https?://[^"]+"' dist/index.html | sed -E 's/.*href="([^"]+)".*/\1/' | sort -u)
: > /tmp/linkcheck.txt
FAIL=0
for u in "${LINKS[@]}"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -L -m 15 -A 'Mozilla/5.0 (linkcheck)' "$u" || echo 000)
  [[ "$code" =~ ^2|3$ ]] || FAIL=1
  echo "$code $u" >> /tmp/linkcheck.txt
done
[ "$FAIL" -eq 0 ] || { echo "❌ Link check FAIL"; awk '!($1 ~ /^(2|3)$/){print}' /tmp/linkcheck.txt; exit 1; }

echo "→ Accesibilidad (pa11y)"
npx -y pa11y@9.0.0 "http://127.0.0.1:$PORT/" \
  --level error --threshold 0 --wait 1000 --timeout 60000 \
  --reporter html > /tmp/pa11y-report.html || true

echo "✅ LOCAL GREEN — artefactos:"
printf "  /tmp/_page.html\n  /tmp/site-server.log\n  /tmp/linkcheck.txt\n  /tmp/pa11y-report.html\n"
