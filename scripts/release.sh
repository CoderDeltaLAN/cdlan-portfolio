#!/usr/bin/env bash
set -euo pipefail
cd /home/user/Proyectos/cdlan-portfolio
./scripts/preflight.sh
echo
echo "✅ Local GREEN."
echo "Publicación MANUAL (si quieres):"
echo "  git add -A && git commit -m 'release: manual' && git push origin main"
echo
echo "Tras el push, revisa:"
echo "  gh run list --limit 20 --json name,displayTitle,conclusion,createdAt -q '.[] | [.createdAt,.name,.displayTitle,.conclusion] | @tsv'"
