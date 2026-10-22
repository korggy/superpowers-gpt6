#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
: "${GPT6_TEST_MARKETPLACE:?Set GPT6_TEST_MARKETPLACE to the built BetterGood marketplace directory}"
node --test "$REPO_ROOT/tests/package/test-gpt6-package.mjs"
