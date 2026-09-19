# Testing skills with subagents

Use this reference within an accepted skill-authoring or evaluation workflow.
Evaluate the requested behavior, including correct decisions to proceed, ask,
or stop. Obedience to a sentence is not sufficient if the task outcome is wrong.

## Define the comparison before editing

Record the intended policy, affected skills, and baseline source revision.
Freeze the relevant files. Prepare realistic inputs with clear authority,
constraints, available evidence, and pressures that could expose mistakes.

For an existing skill, compare the frozen prior guidance with the candidate.
A no-guidance control is useful when asking whether a skill adds value; it is
optional for an explicitly requested compatibility or policy change. A baseline
pass stays a pass. Do not increase pressure solely to manufacture a violation.

Keep scenario inputs separate from the grading rubric. A probe should ask the
worker for its next human-facing response and planned actions, or provide a
sandbox in which it can actually perform the task. Do not tell the worker the
desired answer through labels such as "unnecessary approval test."

## Run independent sessions

Use a fresh-context worker for each comparison arm. Give it the task context,
the relevant skill files, and any host constraints the real agent would have.
Keep scenario wording and harness settings consistent across arms. Prevent
baseline workers from reading candidate files, results, or the scoring rubric.

Prefer one scenario per session. Closely related scenarios may share a probe
when resources are limited, but disclose possible within-probe contamination.
For multi-turn cases, supply realistic human replies rather than treating
silence as acceptance.

Do useful independent work while probes run. Follow the host's dispatch,
model, effort, and waiting contracts. Do not fabricate tools or unavailable
telemetry. A simulated next-action response is a decision probe, not evidence
that implementation or a real harness integration worked.

## Grade against the task

Read each output and record concrete evidence for:

| Dimension | Questions |
|---|---|
| Scope and authority | Did the agent perform only the requested work? Did it honor approval, delegation, and retained checkpoints? |
| Clarification | Did it surface a material decision with useful options before affected work? |
| Unnecessary pauses | Did it repeat settled questions or ask about unrelated future work? |
| Progress and completion | Did it continue independent authorized work and keep unresolved requirements pending? |
| Verification | Did it use relevant evidence, run required checks, and avoid repeats without changed risk? |
| Effort | What tool calls, elapsed time, tokens, repeated checks, or user decisions were actually observed? |

Record the exact question or action supporting each judgment. A concise answer
is not automatically more efficient, and a longer answer is not automatically
worse. Mark unavailable measurements explicitly. Keep baseline/environment
failures separate from skill-caused failures.

Use source checks for metadata, links, helper behavior, and packaging. They do
not prove that a model followed the policy. Conversely, a successful decision
probe does not validate an installed plugin's startup or tool wiring.

## Refine and report

When a candidate regresses, identify the conflicting rule and revise narrowly.
Rerun affected cases after a material edit. Repeat uncertain or variable cases
before claiming robustness or a measured improvement; report sample counts and
all outcomes, including unchanged passes. Small samples are smoke evidence.

Preserve scenario inputs, guidance revisions or snapshots, outputs, and grading
notes. Record model, host, and effort settings when exposed. If the exact model
build or effort is unavailable, say so instead of guessing from a display name.

For this repository, `tests/gpt6/clarification-scenarios.json` provides reusable
decision probes and `tests/gpt6/README.md` explains execution and scoring.
These fixtures stay outside installed skill instructions.

The older worked example at [examples/CLAUDE_MD_TESTING.md](examples/CLAUDE_MD_TESTING.md)
illustrates pressure-scenario construction. Its historical TDD choices and
deployment instructions are not current policy; use the accepted verification,
invocation, and decision-checkpoint guidance when grading new runs.
