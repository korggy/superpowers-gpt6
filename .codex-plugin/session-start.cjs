const { readFileSync } = require('node:fs');
const { join } = require('node:path');

const policy = readFileSync(join(__dirname, '../skills/using-superpowers/references/invocation-policy.md'), 'utf8').trim();
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'SessionStart',
    additionalContext: policy,
  },
}));
