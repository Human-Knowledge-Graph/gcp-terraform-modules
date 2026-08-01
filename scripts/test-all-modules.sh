#!/usr/bin/env bash
# Runs `terraform test` for every module that has tests, anywhere in the repo
# (including nested paths like modules/observability/*/* that the Makefile's
# shallow `modules/*/` glob does not reach). Mirrors the discovery logic used
# in .github/workflows/ci.yml so local runs match CI.
#
# Usage: scripts/test-all-modules.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DIRS=$(
  find . -path "*/tests/*.tftest.hcl" \
         -not -path "*/.terraform/*" \
  | sed 's|/tests/[^/]*$||' \
  | sort -u
)

if [ -z "$DIRS" ]; then
  echo "No modules with tests found."
  exit 0
fi

PASSED=()
FAILED=()

while IFS= read -r dir; do
  echo "=== $dir ==="
  if (cd "$dir" && terraform init -backend=false -input=false > /dev/null && terraform test); then
    PASSED+=("$dir")
  else
    FAILED+=("$dir")
  fi
  echo
done <<< "$DIRS"

echo "=== Summary ==="
echo "Passed: ${#PASSED[@]}"
for dir in "${PASSED[@]-}"; do [ -n "$dir" ] && echo "  ok   $dir"; done
echo "Failed: ${#FAILED[@]}"
for dir in "${FAILED[@]-}"; do [ -n "$dir" ] && echo "  FAIL $dir"; done

[ "${#FAILED[@]}" -eq 0 ]
