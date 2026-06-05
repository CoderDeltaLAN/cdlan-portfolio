#!/usr/bin/env bash
set -o pipefail

stop=0

printf '\n== required files ==\n'
for file in README.md LICENSE SECURITY.md index.html .gitignore .nojekyll docs/PORTFOLIO-ROADMAP.md docs/PUBLICATION-CHECKLIST.md docs/CONTENT-GUIDE.md .github/workflows/verify.yml assets/css/styles.css assets/js/main.js; do
  if [ -f "$file" ]; then
    printf '[OK] %s\n' "$file"
  else
    printf '[FAIL] missing %s\n' "$file"
    stop=1
  fi
done

printf '\n== generated/vendor artifacts tracked ==\n'
if git ls-files node_modules dist build .cache .vite .astro 2>/dev/null | grep -q .; then
  printf '[FAIL] generated/vendor artifacts are tracked\n'
  git ls-files node_modules dist build .cache .vite .astro | sed -n '1,80p'
  stop=1
else
  printf '[OK] no generated/vendor artifacts tracked\n'
fi

printf '\n== CRLF check ==\n'
if grep -RIl --exclude-dir=.git $'\r' . | grep -q .; then
  printf '[FAIL] CRLF files found\n'
  grep -RIl --exclude-dir=.git $'\r' . | sed -n '1,80p'
  stop=1
else
  printf '[OK] no CRLF found\n'
fi

printf '\n== trailing whitespace check ==\n'
if grep -RIn --exclude-dir=.git '[[:blank:]]$' . | grep -q .; then
  printf '[FAIL] trailing whitespace found\n'
  grep -RIn --exclude-dir=.git '[[:blank:]]$' . | sed -n '1,80p'
  stop=1
else
  printf '[OK] no trailing whitespace found\n'
fi

printf '\n== obvious sensitive patterns in publishable files ==\n'
if grep -RIn -E 'ghp_|github_pat|BEGIN OPENSSH|BEGIN RSA|client_secret|bearer |authorization:|N8N_WEBHOOK|OPENAI_API|ANTHROPIC_API|GEMINI_API|QDRANT_API|VAPI_API|wa.me/\[' index.html assets README.md 2>/dev/null | grep -q .; then
  printf '[FAIL] possible sensitive or unfinished pattern found\n'
  grep -RIn -E 'ghp_|github_pat|BEGIN OPENSSH|BEGIN RSA|client_secret|bearer |authorization:|N8N_WEBHOOK|OPENAI_API|ANTHROPIC_API|GEMINI_API|QDRANT_API|VAPI_API|wa.me/\[' index.html assets README.md 2>/dev/null | sed -n '1,80p'
  stop=1
else
  printf '[OK] no obvious sensitive or unfinished pattern found in publishable files\n'
fi

printf '\n== HTML basic parse ==\n'
python - <<'PY' || stop=1
from html.parser import HTMLParser
from pathlib import Path

class Parser(HTMLParser):
    pass

p = Path("index.html")
data = p.read_text(encoding="utf-8")
Parser().feed(data)

required = ["<!doctype html", "<html", "<head", "<body", "</html>"]
missing = [x for x in required if x not in data.lower()]

if missing:
    raise SystemExit(f"[FAIL] missing HTML markers: {missing}")

print("[OK] index.html basic parse/check passed")
PY

printf '\n== SEO/security metadata check ==\n'
seo_stop=0

grep -Fq '<link rel="canonical" href="https://coderdeltalan.github.io/cdlan-portfolio/">' index.html || { printf '[FAIL] missing canonical\n'; seo_stop=1; }
grep -Fq '<meta name="robots" content="index, follow, max-image-preview:large">' index.html || { printf '[FAIL] missing robots\n'; seo_stop=1; }
grep -Fq '<meta name="author" content="Yosvel Delta / CDLAN">' index.html || { printf '[FAIL] missing author\n'; seo_stop=1; }
grep -Fq '<meta property="og:title"' index.html || { printf '[FAIL] missing og:title\n'; seo_stop=1; }
grep -Fq '<meta property="og:description"' index.html || { printf '[FAIL] missing og:description\n'; seo_stop=1; }
grep -Fq '<meta property="og:type" content="website">' index.html || { printf '[FAIL] missing og:type\n'; seo_stop=1; }
grep -Fq '<meta property="og:url" content="https://coderdeltalan.github.io/cdlan-portfolio/">' index.html || { printf '[FAIL] missing og:url\n'; seo_stop=1; }
grep -Fq '<meta name="twitter:card" content="summary">' index.html || { printf '[FAIL] missing twitter summary card\n'; seo_stop=1; }
grep -Fq '<meta name="theme-color" content="#000000">' index.html || { printf '[FAIL] missing theme-color\n'; seo_stop=1; }
grep -Fq '<meta name="color-scheme" content="dark">' index.html || { printf '[FAIL] missing color-scheme\n'; seo_stop=1; }
grep -Fq '<meta name="referrer" content="strict-origin-when-cross-origin">' index.html || { printf '[FAIL] missing referrer policy\n'; seo_stop=1; }
grep -Fq 'Content-Security-Policy' index.html || { printf '[FAIL] missing Content-Security-Policy\n'; seo_stop=1; }

if grep -Eq 'http-equiv="X-Frame-Options"|http-equiv="X-XSS-Protection"|http-equiv="Cross-Origin-Opener-Policy"|http-equiv="Cross-Origin-Resource-Policy"|http-equiv="Permissions-Policy"|http-equiv="X-Content-Type-Options"|summary_large_image|twitter:image' index.html; then
  printf '[FAIL] misleading security/image metadata present\n'
  seo_stop=1
fi

if [ "$seo_stop" -eq 0 ]; then
  printf '[OK] SEO/security metadata passed\n'
else
  stop=1
fi

printf '\n== workflow trigger check ==\n'
if grep -q 'chore/\*\*' .github/workflows/verify.yml && grep -q 'feat/\*\*' .github/workflows/verify.yml && grep -q 'fix/\*\*' .github/workflows/verify.yml && grep -q 'pull_request:' .github/workflows/verify.yml; then
  printf '[OK] workflow branch triggers found\n'
else
  printf '[FAIL] workflow branch triggers incomplete\n'
  stop=1
fi

printf '\n== final result ==\n'
if [ "$stop" -eq 0 ]; then
  printf '[OK] verification passed\n'
else
  printf '[FAIL] verification failed\n'
fi

exit "$stop"
