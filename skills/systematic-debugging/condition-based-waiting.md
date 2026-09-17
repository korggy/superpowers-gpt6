# Condition-Based Waiting

## Overview

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.

**Core principle:** Wait for the actual condition you care about, not a guess about how long it takes.

## When to Use

```dot
digraph when_to_use {
    "Test uses setTimeout/sleep?" [shape=diamond];
    "Testing timing behavior?" [shape=diamond];
    "Use controlled time and assert timing contract" [shape=box];
    "Use condition-based waiting" [shape=box];

    "Test uses setTimeout/sleep?" -> "Testing timing behavior?" [label="yes"];
    "Testing timing behavior?" -> "Use controlled time and assert timing contract" [label="yes"];
    "Testing timing behavior?" -> "Use condition-based waiting" [label="no"];
}
```

**Use when:**
- Tests have arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`)
- Tests are flaky (pass sometimes, fail under load)
- Tests timeout when run in parallel
- Waiting for async operations to complete

**For actual timing behavior** (debounce, throttle intervals), prefer the project's controlled clock or timer facilities and assert the timing contract. Waiting for an output alone does not establish when it occurred.

## Core Pattern

```typescript
// ❌ BEFORE: Guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// ✅ AFTER: Waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

## Quick Patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for count | `waitFor(() => items.length >= 5)` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10)` |

## Implementation

Generic polling function:
```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise(r => setTimeout(r, 10)); // Poll every 10ms
  }
}
```

See `condition-based-waiting-example.ts` in this directory for complete implementation with domain-specific helpers (`waitForEvent`, `waitForEventCount`, `waitForEventMatch`) from actual debugging session.

## Common Mistakes

**❌ Polling too fast:** `setTimeout(check, 1)` - wastes CPU
**✅ Fix:** Poll every 10ms

**❌ No timeout:** Loop forever if condition never met
**✅ Fix:** Always include timeout with clear error

**❌ Stale data:** Cache state before loop
**✅ Fix:** Call getter inside loop for fresh data

## Observable Progress and Timer Behavior

```typescript
// This test needs two output chunks, regardless of scheduler delay.
await waitFor(() => outputChunks.length >= 2, 'two output chunks');
expect(outputChunks.length).toBeGreaterThanOrEqual(2);
```

A 200ms wall-clock sleep does not guarantee two callbacks from a 100ms interval. Scheduler delays and callback work can postpone observable progress. Wait for the output or event count that the test actually needs, with a bounded timeout for failure.

When testing the interval itself, use the project's controlled-time facilities: establish when the timer starts, advance to just before its deadline and assert no output, then cross the deadline and assert the expected output. Advance through the next deadline to test subsequent ticks. Use the framework's supported mechanism to settle pending asynchronous work.

Use real elapsed-time waits only for explicit real-time integration requirements where controlled time cannot exercise the behavior. Assert observable results with justified bounds and tolerances; elapsed time alone is not proof that callbacks ran.

## Real-World Impact

From debugging session (2025-10-03):
- Fixed 15 flaky tests across 3 files
- Pass rate: 60% → 100%
- Execution time: 40% faster
- No more race conditions
