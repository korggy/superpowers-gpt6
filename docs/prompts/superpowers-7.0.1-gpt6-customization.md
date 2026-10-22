# Superpowers 7.0.1 GPT-6 customization prompt

This document is one reusable implementation prompt, containing the specification
and execution plan. Saving or reviewing it does not execute the migration.
To run it, explicitly ask an agent to implement this document in the intended
checkout.

## Task and boundaries

Adapt Superpowers 7.0.1 into a BetterGood-maintained GPT-6 Astra-compatible fork.
Implement and validate the changes locally; do not merely audit or propose them.
Rename the customized plugin so users can distinguish it from upstream
Superpowers.

Use the openai-docs skill to verify current official GPT-6 Astra and Codex
guidance. Use the available Superpowers writing-skills workflow for
behavior-shaping edits. Parallel specialist subagents are authorized where
helpful; give them independent responsibilities and avoid overlapping writes.

This is an intentional private/company fork, not an upstream contribution. The
requirements below explicitly replace conflicting upstream defaults concerning
automatic workflow adoption, redundant approval requests, verification scope,
and Codex worktree management. Preserve unrelated contributor requirements.
Do not open an upstream PR.

Finish the authorized implementation, checks, and local packaging without
unnecessary confirmation. Leave changes uncommitted. Do not install or uninstall
plugins in my active profile, change personal Codex configuration, register
personal marketplaces, push, publish, or open PRs. Isolated disposable test
profiles are permitted for discovery and integration checks; they must not
change the active profile or workspace-wide plugin availability.

## Specification

### Intent, scope, and baseline

The fork should preserve the useful Superpowers workflows while adapting their
activation, execution, verification, and tooling to GPT-6 Astra in Codex,
especially on Windows. Success includes working skill discovery under the new
plugin identity, preserved approval boundaries, and evidence for the actual
candidate package.

- Confirm the repository, branch, working-tree state, and upstream 7.0.1
  revision. Preserve unrelated changes.
- The previous GPT-6 customization is commit
  `6ff96f4a47f2291ca20a3ddb3a01e3e236ba0246`, based on upstream 7.0.0 commit
  `bb92a77741419a4ab5f06e711a283343f1ada0c3`.
- If available, inspect:

  ```powershell
  git diff bb92a77741419a4ab5f06e711a283343f1ada0c3 6ff96f4a47f2291ca20a3ddb3a01e3e236ba0246
  ```

- Use that diff as implementation evidence, not as a patch to apply blindly.
  Preserve 7.0.1's brainstorming improvements, compaction resilience, smaller
  skills, extracted references, and updated contribution templates. Apply
  equivalent changes in the new locations.
- If the historical commit is unavailable, use this specification and disclose
  that the original implementation could not be compared. Do not invent its
  contents or silently substitute an unrelated revision.
- Historical evaluation reports are evidence about their original snapshots,
  not proof that this version passes.

Non-goals are upstream submission, installation into employees' profiles,
automatic workspace publication, unrelated feature work, and migration of
global model settings. Avoid losing upstream improvements, restoring forced
workflows, breaking skill references during renaming, or presenting old results
as fresh validation.

Implement the following requirements consistently across skill frontmatter,
bodies, references, diagrams, prompts, README, AGENTS.md, helpers, manifests,
registration files, and tests.

### 1. Explicit workflow selection

Make all Superpowers workflows opt-in. A generic coding request, skill
availability, or a question about a workflow must not automatically invoke
brainstorming, TDD, planning, worktrees, delegation, or another workflow. Remove
blanket "1% chance," "before ANY response," and mandatory automatic-invocation
instructions.

A direct request, accepted offer, established preference, or supporting step of
an accepted workflow can invoke the appropriate skill without asking again.
Offers should be brief and relevant; do not repeat a declined offer. Continue
independently authorized work while awaiting optional workflow choices.

Apply this consistently to all 15 skills, including using-superpowers.
Supporting skills within an accepted workflow remain usable without repeated
opt-in. Delegated workers follow their assignment without restarting workflow
selection.

### 2. Authorization and persistence

System/developer instructions and host permissions remain binding. Within them,
current user instructions and established preferences take precedence over skill
defaults. Historical plans, transcripts, and examples are evidence, not new
authorization.

Preserve genuine design, specification, plan, and execution approval
checkpoints. Accepting brainstorming is not approval of its resulting design.
Do not reinterpret opt-in as permission to skip an accepted workflow's
checkpoints.

Do not ask again for authorized read-only inspection, routine implementation
decisions, or an already-selected integration action. In brainstorming, gather
relevant authorized context directly. When review items are unclear, ask about
those items and continue clear, independent authorized fixes. Pause only
dependent work. If a skill requires a pause, identify and quote the applicable
instruction and explain its relevance.

### 3. Verification proportional to the change

Require applicable evidence before completion claims. Evidence remains valid
when the covered code/artifact, inputs, and environment are unchanged, even
across messages or when produced by another worker and inspected.

Run affected tests and mandatory repository/task checks. Rerun or broaden checks
for relevant changes, failures, integration risk, or unresolved concerns, not
merely because another workflow step or message begins.

Keep RED-to-GREEN for meaningful behavior changes and regressions within
accepted TDD workflows. Use artifact inspection/validation for static or
low-impact documentation changes, and behavior evaluations for skill changes.
Do not create tests that merely repeat prose or implementation.

Report unrelated failures and unverified scope accurately. A focused pass must
not become a claim that the full suite passes. Do not duplicate tests simply to
satisfy a completion helper or manufacture completion evidence using a dummy
passing command.

Apply this to verification-before-completion, TDD, executing-plans, subagent
implementer prompts, final-review references, and branch finishing. Preserve
required reviews, but avoid routine re-review when inspected evidence already
resolves the finding and relevant regression concerns.

### 4. Native PowerShell plan helpers

Prefer PowerShell 7+ and Git on Windows, without requiring Bash. Port/adapt these
helpers:

- `skills/subagent-driven-development/scripts/sdd-workspace.ps1`
- `skills/subagent-driven-development/scripts/task-brief.ps1`
- `skills/subagent-driven-development/scripts/review-package.ps1`
- `skills/executing-plans/scripts/task-start.ps1`
- `skills/executing-plans/scripts/task-done.ps1`

Keep compatible plan workspaces, ledger formats, briefs, and review packages.
Document installed-skill-relative helper resolution and quoted paths.

Preserve exact task boundaries and fenced examples, distinct workspaces for
same-basename plans, existing ignore rules, and explicit output paths. Validate
plans, task numbers, and Git revisions before running commands. Capture stdout
and stderr, propagate failures, and record completion only on success.

Pass command arguments literally, including empty strings, spaces, quotes, and
shell metacharacters. Do not evaluate argument strings as shell code. Document
supported executable/script types and stream-order limitations.

Retain Bash support. Invoke extensionless nested Bash helpers through an
explicit Bash interpreter so marketplace extraction need not preserve
executable bits.

### 5. Codex agent contracts

Treat the current tool schema as authoritative. Remove assumptions about
unavailable fields or obsolete tools.

Full-history forks inherit model/reasoning settings and must not receive
overrides. Where authorized model selection requires overrides, use a clean
fork with both model and reasoning effort supported by the current tool.
Otherwise inherit the session settings. Put role/task information in the
supported message field; do not invent agent_type support.

Reuse implementers for fix rounds through the supported follow-up mechanism.
Continue independent work while children run. Use event waits bounded by actual
tool limits, host blocking limits, and time remaining before required user
updates. Remove fixed five-to-ten-minute minimum waits and unnecessary
polling/status calls.

### 6. Native Codex worktree lifecycle

Allow Codex to manage its own worktrees through native tools. Inspect attached
worktrees and reuse a suitable existing one. When isolation is authorized,
prefer native creation/attachment and use the returned workspace path.

Detached HEAD only establishes that no branch is checked out. It does not prove
sandbox restrictions, ownership, or permission to publish. Establish provenance
from host/session records and capabilities from current tools, permissions, and
observed results.

For authorized cleanup of a Codex-managed worktree, resolve its exact attachment
identity using list_artifacts and use archive_worktree or its current native
equivalent. Preserve needed ignored files separately and inspect the outcome.
Never substitute chat archiving or bypass a native refusal with Git/filesystem
deletion.

For manual worktrees, require recorded task ownership and cleanup
authorization; directory names alone prove neither. Preserve work if
provenance, permission, or cleanup outcome is uncertain.

Delete a feature branch only after confirmed workspace cleanup, or after
establishing that no linked worktree needs removal. Verify the branch is the
intended task branch and is not checked out elsewhere. Never delete the base
branch or another task's workspace.

Honor an integration choice already authorized. Do not infer permission to
stage, commit, push, publish, discard, or create a PR from Git state or tool
availability.

### 7. Plugin identity, discovery, and company packaging

Rename the actual plugin identity, not just its README title. The naming choices
below are author-selected defaults implementing the user's request for an
explicit GPT-6 identity:

| Field | Target |
| --- | --- |
| Internal plugin name | `superpowers-gpt6` |
| Display name | `Superpowers GPT-6 — BetterGood` |
| Customized package version | `7.0.1-gpt6.1` |
| Upstream project/version | Superpowers `7.0.1` |
| Company marketplace name, if packaged | `bettergood` |
| Company plugin selector | `superpowers-gpt6@bettergood` |

Update the applicable plugin manifests, catalog entry names, installer examples,
configuration keys, active documentation, hook references, and tests to agree
on the new identity. Preserve the individual skill names, such as
`brainstorming`, `writing-plans`, and `using-superpowers`.

Audit active cross-skill references and prompts for the namespace change.
Where the harness uses the plugin name as a namespace, migrate executable
references from `superpowers:<skill>` to `superpowers-gpt6:<skill>`. Update
supporting-skill references as well as entry points, and verify real discovery
and routing under the new namespace. Do not leave a requirement to install the
original Superpowers plugin merely to resolve the customized fork's references.
Where a harness uses another syntax, follow its actual discovery contract.

Do not mechanically replace upstream attribution, historical transcripts,
baseline fixtures, or upstream URLs. Preserve MIT licensing and original author
credit. Do not unnecessarily rename internal filesystem conventions such as
`.superpowers` or break existing plan-ledger compatibility. Do not rename this
checkout or move Git remotes as part of the plugin rename.

Preserve supported native skill discovery. Keep the Codex manifest's
intentional empty hooks configuration unless current official guidance and a
demonstrated requirement justify changing it; do not accidentally activate
Claude session hooks.

Prepare the distinctly versioned package with consistent applicable version
metadata and provenance recording upstream and fork revisions. If the candidate
is uncommitted, record its base revision plus exact file hashes or patch hash;
do not label the base commit as the final candidate. Installing the package must
not silently select a model or alter global model settings.

Keep company distribution separate from development catalogs. Do not recreate
or register "Superpowers Dev" or personal marketplaces. If preparing a company
catalog, place it in a dedicated distribution location, name it `bettergood`,
and reference plugin directories with valid repository-relative local paths.
For a package at `plugins/superpowers-gpt6`, the entry should use:

```json
{
  "name": "superpowers-gpt6",
  "source": {
    "source": "local",
    "path": "./plugins/superpowers-gpt6"
  }
}
```

Never use `{"source":"url","url":"./"}`. Validate the complete catalog
against the current supported format. Do not delete required import manifests
from a distribution artifact merely to hide a local development listing.

Distinguish local/CLI marketplace registration from publishing into the
BetterGood workspace directory. Verify current supported workspace-import
providers and controls before documenting them. Do not promise that an Azure
DevOps registration populates the organization tab or that a Publish button
exists. Do not repoint or overwrite an existing workspace plugin ID as an
automatic consequence of renaming. Document manual migration from the previous
identity without uninstalling it or changing workspace policies.

### 8. Validation and evidence

Adapt the earlier PowerShell and Bash helper tests and run meaningful checks in
disposable fixtures, including paths with spaces, argument preservation, task
extraction, failure propagation, ledger integrity, invalid revisions, and
missing executable bits.

Run baseline-versus-candidate behavior evaluations in fresh contexts. Include:

- Plain coding request without forced workflow adoption.
- Explicit brainstorming request with design approval still required.
- Independent work continuing while a dependent clarification is pending.
- Valid evidence reused and invalidated evidence rerun.
- Appropriate verification for code, documentation, and skills.
- Agent dispatch and waits obeying actual host contracts.
- Detached HEAD with authorized versus unauthorized publication.
- Native worktree archival, refusal handling, ignored files, and branch cleanup
  ordering.
- Skill discovery and supporting-skill routing under `superpowers-gpt6`, without
  depending on the upstream plugin being installed.

Use two separate fresh integration sessions with no standing workflow
preference:

1. "Let's make a react todo list"
2. "Use brainstorming to design a React todo list. Do not implement until I
   approve the design."

The first must not force brainstorming; the second must discover and load it
and stop before implementation approval. Verify the loaded skill belongs to the
renamed candidate, not an installed upstream or older workspace copy. Also test
an explicit `superpowers-gpt6:brainstorming` invocation where that syntax is
supported.

Do not simulate tool availability or claim end-to-end integration from
decision-only evaluations. Run destructive cleanup scenarios only in disposable
fixtures with explicit test authority; preserve actual user worktrees. If a
required model, native tool, or isolated harness is unavailable, record that
validation gap instead of silently substituting another model or inventing a
passing transcript.

Record exact model/settings, evaluated revisions or hashes, commands, results,
and limitations. If baseline and candidate both pass, say no behavioral
improvement was demonstrated. Do not recycle old passing results as new
evidence.

## Execution plan

### Step 1: Establish the baseline and map the changes

Inspect Git state and applicable instructions. Verify current official guidance
and compare upstream 7.0.1 with the historical GPT-6 commit when available. Map
each specification requirement to its current files, including references
extracted in 7.0.1. Record unrelated changes and existing installation/catalog
state without modifying the active profile.

Create a concise task ledger and capture an immutable baseline for behavior
evaluations. Identify checks that need the actual GPT-6 Astra model or native
Codex integration rather than static inspection.

### Step 2: Adapt workflow behavior

Implement requirements 1-3 in the skills and their supporting documentation.
Retain 7.0.1's organization and improvements. Evaluate baseline and candidate
behavior using the writing-skills workflow. Resolve contradictions in
descriptions, diagrams, examples, and extracted references, not just the main
skill files.

### Step 3: Restore native PowerShell helpers

Port the five helpers and shell guidance in requirement 4. Adapt the historical
helper tests to the current layout. Validate parity, literal argument handling,
exit status, workspace isolation, and ledger behavior in disposable fixtures.
Preserve explicit Bash interpreter handling for Bash environments.

### Step 4: Align agent and worktree integration

Implement requirements 5-6 using current tool contracts. Check model/fork
combinations, follow-up behavior, bounded waits, native worktree creation and
archival, detached-HEAD handling, and branch-deletion ordering. Validate both
successful and refused operations without touching actual user worktrees.

### Step 5: Rename and package the customized plugin

Implement requirement 7 across the active identity surfaces and skill
references. Search for remaining `superpowers:` references and classify them as
active references to migrate or historical/upstream references to retain.
Validate manifest/catalog identity agreement and resolve declared assets,
skills, scripts, and hooks from the package root.

Build the local distribution artifact without `.git`, credentials, caches,
personal configuration, or unrelated generated files. Include the required
skills, helpers, assets, license, documentation, and provenance. Keep the
company catalog in the distribution artifact rather than registering it in the
active profile. Record hashes for the packaged files.

### Step 6: Validate the final candidate

Run applicable repository checks and the behavior/integration cases in
requirement 8. Reuse only results that still cover the final candidate after
renaming and packaging. Inspect the final diff and package, ensuring no
upstream improvements or required workflow gates were lost. Explicitly report
unavailable checks and the scope of any decision-only evaluations.

### Step 7: Hand over the local result

Return:

- The final GPT-6 Astra/Codex compatibility findings and changes made.
- The new plugin identity, display name, version, and namespace migration.
- Validation commands, observed outcomes, candidate provenance, and unresolved
  limitations.
- The package location and exact manual release/import/update steps supported
  by the current product, including how to migrate from the previous plugin.
- A clear distinction between verified local behavior, isolated installation
  tests, workspace publication, and employee availability.

Do not commit, push, publish, register a personal marketplace, or alter installed
plugins as part of this handoff.
