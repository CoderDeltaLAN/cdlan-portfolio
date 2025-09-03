#!/usr/bin/env bash
set -euo pipefail
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
for id in $(gh run list --limit 100 --json databaseId,conclusion \
  -q '.[] | select(.conclusion=="failure") | .databaseId'); do
  echo "Deleting failed run $id"
  gh api -X DELETE "repos/${REPO}/actions/runs/${id}"
done
echo "Estado actual:"
gh run list --limit 20 --json name,displayTitle,conclusion,createdAt \
  -q '.[] | [.createdAt,.name,.displayTitle,.conclusion] | @tsv'
