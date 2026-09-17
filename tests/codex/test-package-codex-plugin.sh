#!/usr/bin/env bash
# Portable packaging regressions, including committed-ref and preview behavior.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"
if command -v python3 >/dev/null 2>&1; then
  exec python3 -m unittest discover -s tests/codex -p test_package.py
fi
exec python -m unittest discover -s tests/codex -p test_package.py
