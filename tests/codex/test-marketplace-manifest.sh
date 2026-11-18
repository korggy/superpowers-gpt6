#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
: "${GPT6_TEST_MARKETPLACE:?Set GPT6_TEST_MARKETPLACE to the built BetterGood marketplace directory}"
node --test "$REPO_ROOT/tests/package/test-gpt6-package.mjs"

# Exercise the fork guard before any upstream operation. --help is a local
# no-op even if a guard is accidentally removed.
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/.codex-plugin" "$fixture/scripts"
printf '%s\n' '{"name":"superpowers-gpt6"}' > "$fixture/.codex-plugin/plugin.json"
for script in package-codex-plugin.sh sync-to-codex-plugin.sh; do
    cp "$REPO_ROOT/scripts/$script" "$fixture/scripts/$script"
    result=0
    message="$(bash "$fixture/scripts/$script" --help 2>&1)" || result=$?
    if [[ $result -ne 2 || $message != *BetterGood* ]]; then
        echo "$script did not stop at the BetterGood guard (status $result): $message" >&2
        exit 1
    fi
done
echo "Both upstream release scripts stopped at the BetterGood guard."
