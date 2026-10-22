#!/usr/bin/env bash
# Tests for executing-plans' bookkeeping helpers: scripts/task-start extracts
# the brief and records BASE in one call; scripts/task-done runs the task's
# test command, records the result in the ledger, and refuses to record a
# failing task.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EP_SCRIPTS="$REPO_ROOT/skills/executing-plans/scripts"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

main() {
    echo "=== Test: executing-plans scripts ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    git init -q -b main "$TEST_ROOT/repo"
    local repo
    repo="$(cd "$TEST_ROOT/repo" && git rev-parse --show-toplevel)"
    # Same spelling as the scripts print (pwd), not rev-parse's C:/... on Git Bash.
    repo="$(cd "$repo" && pwd)"
    local git_id=(-c user.email=t@example.com -c user.name=t -c commit.gpgsign=false)

    cat > "$repo/plan.md" <<'PLAN'
# Plan

## Task 1: First thing

Do the first thing.

   ~~~~markdown
## Task 2: Fenced fake task
   ~~~
## Task 10: Shorter fence does not close the example
   ~~~~
Keep after the tilde fence.

````markdown
## Task 2: Another fenced fake task
```
## Task 10: Still in the longer fence
````
Keep after the longer fence.

## Task 2: Second thing

Do the second thing.
PLAN
    ( cd "$repo" && git add plan.md && git "${git_id[@]}" commit -qm fixture )
    local base
    base="$(cd "$repo" && git rev-parse HEAD)"

    # --- task-start: argument validation ---
    local rc=0
    (cd "$repo" && "$EP_SCRIPTS/task-start" plan.md >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "task-start without a task number errors with exit 2"
    else
        fail "task-start without a task number errors with exit 2 (got $rc)"
    fi

    # --- task-start: brief path + BASE in one call ---
    local out
    out="$(cd "$repo" && "$EP_SCRIPTS/task-start" plan.md 1)"
    if [[ "$out" == *"brief: $repo/.superpowers/sdd/plan/task-1-brief.md"* ]]; then
        pass "task-start prints the brief path under the plan's workspace"
    else
        fail "task-start prints the brief path under the plan's workspace"
        echo "    got: $out"
    fi
    if [[ "$out" == *"base: $base"* ]]; then
        pass "task-start prints BASE as the current HEAD"
    else
        fail "task-start prints BASE as the current HEAD"
        echo "    got: $out"
    fi
    if [[ -s "$repo/.superpowers/sdd/plan/task-1-brief.md" ]]; then
        pass "task-start writes the brief file"
    else
        fail "task-start writes the brief file"
    fi

    # --- task-done: records a passing task ---
    ( cd "$repo" && echo x > work.txt && git add work.txt && git "${git_id[@]}" commit -qm "task 1" )
    local head
    head="$(cd "$repo" && git rev-parse HEAD)"
    out="$(cd "$repo" && "$EP_SCRIPTS/task-done" plan.md 1 "$base" -- sh -c 'echo "Ran 3 tests"; echo OK')"
    rc=$?
    local ledger="$repo/.superpowers/sdd/plan/progress.md"
    local expected="Task 1: complete (commits ${base:0:7}..${head:0:7}, tests: sh -c 'echo \"Ran 3 tests\"; echo OK' → OK)"
    if [[ -f "$ledger" ]] && grep -qF "$expected" "$ledger"; then
        pass "task-done appends the completion line with commit range and test result"
    else
        fail "task-done appends the completion line with commit range and test result"
        echo "    expected: $expected"
        echo "    ledger:"; sed 's/^/      /' "$ledger" 2>/dev/null || echo "      (missing)"
    fi
    if [[ "$out" == *"OK"* ]]; then
        pass "task-done prints the tail of the test output"
    else
        fail "task-done prints the tail of the test output"
        echo "    got: $out"
    fi
    if [[ -s "$repo/.superpowers/sdd/plan/task-1-tests.log" ]]; then
        pass "task-done keeps the full test output in the workspace"
    else
        fail "task-done keeps the full test output in the workspace"
    fi

    # --- task-done: refuses to record a failing task ---
    rc=0
    out="$(cd "$repo" && "$EP_SCRIPTS/task-done" plan.md 2 "$head" -- sh -c 'echo "FAILED (errors=1)"; exit 1' 2>&1)" || rc=$?
    if [[ "$rc" -ne 0 ]]; then
        pass "task-done exits non-zero when the test command fails"
    else
        fail "task-done exits non-zero when the test command fails"
    fi
    if ! grep -q "Task 2: complete" "$ledger"; then
        pass "task-done does not record a failing task as complete"
    else
        fail "task-done does not record a failing task as complete"
    fi
    if [[ "$out" == *"FAILED"* ]]; then
        pass "task-done shows the failing output"
    else
        fail "task-done shows the failing output"
        echo "    got: $out"
    fi

    # --- task-done: records a passing task whose test command prints nothing ---
    # https://github.com/obra/superpowers/issues/2385 -- under `set -euo
    # pipefail`, the ledger's `grep -v '^[[:space:]]*$' log | tail -n 1`
    # exits 1 on an empty/blank log, which used to abort the whole script
    # (silently, no ledger line) even though the test command itself passed.
    ( cd "$repo" && echo y > work2.txt && git add work2.txt && git "${git_id[@]}" commit -qm "task 2" )
    local head2
    head2="$(cd "$repo" && git rev-parse HEAD)"
    rc=0
    out="$(cd "$repo" && "$EP_SCRIPTS/task-done" plan.md 2 "$head" -- true 2>&1)" || rc=$?
    if [[ "$rc" -eq 0 ]]; then
        pass "task-done exits 0 when a passing test command prints nothing"
    else
        fail "task-done exits 0 when a passing test command prints nothing (got rc=$rc)"
        echo "    got: $out"
    fi
    local expected2="Task 2: complete (commits ${head:0:7}..${head2:0:7}, tests: true → (no output))"
    if [[ -f "$ledger" ]] && grep -qF "$expected2" "$ledger"; then
        pass "task-done records a passing task that printed no output"
    else
        fail "task-done records a passing task that printed no output"
        echo "    expected: $expected2"
        echo "    ledger:"; sed 's/^/      /' "$ledger" 2>/dev/null || echo "      (missing)"
    fi

    # Validation must precede command execution and output-file replacement.
    local marker="$repo/must not run"
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 99 "$base" -- sh -c 'touch "$1"' sh "$marker" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 3 && ! -e "$marker" ]]; then pass "unknown task prevents command side effects"; else fail "unknown task prevents command side effects (rc=$rc)"; fi
    rm -f -- "$marker"
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md ../escape "$base" -- sh -c 'touch "$1"' sh "$marker" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 && ! -e "$marker" ]]; then pass "invalid task ID prevents command side effects"; else fail "invalid task ID prevents command side effects (rc=$rc)"; fi
    rm -f -- "$marker"
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 1 --help -- sh -c 'touch "$1"' sh "$marker" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 && ! -e "$marker" ]]; then pass "option-like revision prevents command side effects"; else fail "option-like revision prevents command side effects (rc=$rc)"; fi

    local brief="$repo/.superpowers/sdd/plan/task-1-brief.md"
    if grep -qF 'Keep after the tilde fence.' "$brief" && grep -qF 'Keep after the longer fence.' "$brief" && ! grep -qF 'Do the second thing.' "$brief"; then
        pass "task extraction handles indented, tilde, and longer code fences"
    else fail "task extraction handles indented, tilde, and longer code fences"; fi
    local explicit="$repo/explicit brief.md"
    printf 'preserve me\n' > "$explicit"
    rc=0
    (cd "$repo" && bash "$SDD_SCRIPTS/task-brief" plan.md 99 "$explicit" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 3 && "$(cat "$explicit")" == 'preserve me' ]]; then pass "missing task preserves existing output"; else fail "missing task preserves existing output"; fi

    # Argument boundaries, empty strings, and shell metacharacters remain data.
    local argv=("" "with spaces" 'say "hello"' "single'quote" '; touch should-not-exist' 'a&b|c' '$()' 'trailing\' $'line one\nline two')
    local expected_args="$repo/expected args"
    printf '<%s>\n' "${argv[@]}" > "$expected_args"
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 1 "$base" -- printf '<%s>\n' "${argv[@]}" >/dev/null)
    if cmp -s "$expected_args" "$repo/.superpowers/sdd/plan/task-1-tests.log" && [[ ! -e "$repo/should-not-exist" ]]; then pass "command argv is literal and preserves empty arguments"; else fail "command argv is literal and preserves empty arguments"; fi
    if ! grep -q '^line two' "$ledger"; then pass "argument newlines do not split ledger records"; else fail "argument newlines do not split ledger records"; fi

    local evidence="$repo/existing evidence.log"
    printf 'existing checks PASS\n' > "$evidence"
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 2 "$base" --evidence "$evidence" "$head2" 0 'earlier checks' >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 0 ]] && grep -qF 'recorded evidence' "$ledger"; then pass "recorded evidence avoids a dummy verification command"; else fail "recorded evidence avoids a dummy verification command"; fi
    local before
    before=$(cat "$ledger")
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 2 "$base" --evidence "$evidence" "$base" 0 'stale checks' >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 3 && "$(cat "$ledger")" == "$before" ]]; then pass "evidence for another HEAD cannot complete a task"; else fail "evidence for another HEAD cannot complete a task"; fi
    rc=0
    (cd "$repo" && bash "$EP_SCRIPTS/task-done" plan.md 2 "$base" --evidence "$evidence" "$head2" 23 'failed checks' >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 23 && "$(cat "$ledger")" == "$before" ]]; then pass "recorded failure propagates without ledger completion"; else fail "recorded failure propagates without ledger completion"; fi

    # Archive extraction can strip all helper execute bits. Exercise the full
    # nested chain in an isolated copy, including sdd-workspace and task-brief.
    local copied="$TEST_ROOT/helpers without executable bits"
    mkdir -p "$copied/skills"
    cp -R "$REPO_ROOT/skills/executing-plans" "$REPO_ROOT/skills/subagent-driven-development" "$copied/skills/"
    chmod -x "$copied/skills/executing-plans/scripts/"* "$copied/skills/subagent-driven-development/scripts/"*
    rc=0
    (cd "$repo" && bash "$copied/skills/executing-plans/scripts/task-start" plan.md 1 >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 0 ]]; then pass "task-start works with nested execute bits stripped"; else fail "task-start works with nested execute bits stripped (rc=$rc)"; fi
    rc=0
    (cd "$repo" && bash "$copied/skills/executing-plans/scripts/task-done" plan.md 1 "$base" -- printf 'verification PASS\n' >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 0 ]]; then pass "task-done works with nested execute bits stripped"; else fail "task-done works with nested execute bits stripped (rc=$rc)"; fi

    printf '## Task 1: blocked workspace\n' > "$repo/blocked.md"
    printf 'file prevents workspace directory creation\n' > "$repo/.superpowers/sdd/blocked"
    rc=0
    (cd "$repo" && timeout 5 bash "$SDD_SCRIPTS/sdd-workspace" blocked.md >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then pass "workspace I/O failure exits instead of looping on collisions"; else fail "workspace I/O failure exits instead of looping on collisions (rc=$rc)"; fi

    echo
    if [[ "$FAILURES" -eq 0 ]]; then
        echo "PASS"
    else
        echo "FAIL ($FAILURES)"
        exit 1
    fi
}

main "$@"
