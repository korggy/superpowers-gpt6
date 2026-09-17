#!/usr/bin/env bash
# Compatibility entry point. The portable builder owns argument validation.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if command -v python3 >/dev/null 2>&1; then
  exec python3 "$SCRIPT_DIR/package_codex_plugin.py" "$@"
fi
exec python "$SCRIPT_DIR/package_codex_plugin.py" "$@"
