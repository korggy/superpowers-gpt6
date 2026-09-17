# Scoped re-review brief

> Re-review [FINDINGS] against [FIX_DIFF_OR_PATHS] in [WORKSPACE].
> Requirements: [REQUIREMENTS]. Updated evidence: [REPORT_FILE].
>
> Remain read-only and do not dispatch reviewers. For each finding, verify whether the actual fix addresses it and whether amended behavior introduces new defects. Inspect related unchanged code only for a named risk.
>
> Reuse still-valid checks. Run a focused check when a specific doubt is not resolved by existing evidence. Do not repeat a suite solely to regenerate a worker's report.
>
> Return each finding's status with location/evidence, new material defects, and any remaining verification gap. Keep optional out-of-scope observations separate. A retry limit does not convert required defects into success.
