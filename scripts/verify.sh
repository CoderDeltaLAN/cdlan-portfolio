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

printf '\n== accessibility baseline check ==\n'
a11y_stop=0

grep -Fq '<label for="fName" data-t="form_name">' index.html || { printf '[FAIL] missing label for fName\n'; a11y_stop=1; }
grep -Fq '<label for="fEmail" data-t="form_email">' index.html || { printf '[FAIL] missing label for fEmail\n'; a11y_stop=1; }
grep -Fq '<label for="fSubject" data-t="form_subject">' index.html || { printf '[FAIL] missing label for fSubject\n'; a11y_stop=1; }
grep -Fq '<label for="fMsg" data-t="form_msg">' index.html || { printf '[FAIL] missing label for fMsg\n'; a11y_stop=1; }
grep -Fq '@media (pointer:coarse), (hover:none)' index.html || { printf '[FAIL] missing touch cursor fallback\n'; a11y_stop=1; }
grep -Fq '.cursor-dot,.cursor-ring{display:none!important}' index.html || { printf '[FAIL] missing custom cursor hide fallback\n'; a11y_stop=1; }
grep -Fq '@media(prefers-reduced-motion:reduce)' index.html || { printf '[FAIL] missing reduced motion media query\n'; a11y_stop=1; }

if [ "$a11y_stop" -eq 0 ]; then
  printf '[OK] accessibility baseline passed\n'
else
  stop=1
fi

printf '\n== structural integrity check ==\n'
python - <<'STRUCTPY' || stop=1
from html.parser import HTMLParser
from pathlib import Path
import json
import re

html = Path("index.html").read_text(encoding="utf-8")
errors = []

class Parser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.hrefs = []
        self.title_count = 0
        self.h1_count = 0
        self.jsonld_blocks = []
        self.in_jsonld = False
        self.jsonld_buffer = []

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)

        if "id" in attrs_dict:
            self.ids.append(attrs_dict["id"])

        if tag == "a" and "href" in attrs_dict:
            self.hrefs.append(attrs_dict["href"])

        if tag == "title":
            self.title_count += 1

        if tag == "h1":
            self.h1_count += 1

        if tag == "script" and attrs_dict.get("type") == "application/ld+json":
            self.in_jsonld = True
            self.jsonld_buffer = []

    def handle_data(self, data):
        if self.in_jsonld:
            self.jsonld_buffer.append(data)

    def handle_endtag(self, tag):
        if tag == "script" and self.in_jsonld:
            self.jsonld_blocks.append("".join(self.jsonld_buffer))
            self.in_jsonld = False
            self.jsonld_buffer = []

parser = Parser()
parser.feed(html)

if parser.title_count != 1:
    errors.append(f"title count must be 1, found {parser.title_count}")

if parser.h1_count != 1:
    errors.append(f"h1 count must be 1, found {parser.h1_count}")

duplicate_ids = sorted({item for item in parser.ids if parser.ids.count(item) > 1})
if duplicate_ids:
    errors.append("duplicate ids: " + ", ".join(duplicate_ids))

ids = set(parser.ids)
broken_anchors = sorted({
    href for href in parser.hrefs
    if href.startswith("#") and href != "#" and href[1:] not in ids
})
if broken_anchors:
    errors.append("broken internal anchors: " + ", ".join(broken_anchors))

if not parser.jsonld_blocks:
    errors.append("missing JSON-LD block")

for number, block in enumerate(parser.jsonld_blocks, 1):
    try:
        json.loads(block)
    except Exception as exc:
        errors.append(f"invalid JSON-LD block {number}: {exc}")

blocked = re.findall(
    r"senior|MÁXIMO NIVEL|24/7|latencia|<200|Claude Opus|Gemini 3\.5|GPT-5\.5|Qwen3|RTX 4070|OWASP|GDPR|HIPAA|SOC2|SOC 2|\+40|Rúbrica|cero alucinaciones|quick wins|ROI estimado|50% upfront|Retainer|producción cliente|Control total|sin dependencia de cloud|Observabilidad completa",
    html,
    re.IGNORECASE,
)

if blocked:
    errors.append("blocked claims found: " + ", ".join(sorted(set(blocked))))

if errors:
    print("[FAIL] structural integrity failed")
    for error in errors:
        print(error)
    raise SystemExit(1)

print("[OK] structural integrity passed")
STRUCTPY

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
