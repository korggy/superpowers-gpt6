# GitHub issues

For this BetterGood fork, search and report against `korggy/superpowers-gpt6`.
Use `obra/superpowers` only when your partner explicitly selects upstream and
the evidence concerns unmodified upstream behavior. Apply the upstream
contribution requirements in that case; a fork-specific issue belongs here.
Confirm the destination as part of reviewing the proposed report.

Use `gh` when it is installed and authenticated; it handles auth, rate
limits, and JSON. Fall back to the public API with curl, then to a URL
your partner opens.

## Search

```bash
gh search issues --repo korggy/superpowers-gpt6 --limit 10 "<terms>" \
  --json number,state,title --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
```

Without `gh` (unauthenticated, 10 requests a minute):

```bash
curl -s -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:korggy/superpowers-gpt6+is:issue+<url-encoded terms>&per_page=10" \
  | jq -r '.items[] | "\(.number)\t\(.state)\t\(.title)"'
```

Without curl, hand over `https://github.com/korggy/superpowers-gpt6/issues?q=<terms>`.

## File

Write the filled `templates/issue.md` to the workspace and show the exact
text. After approval:

```bash
gh issue create --repo korggy/superpowers-gpt6 --title "<title>" --body-file <path>
```

Add labels only if they exist in the selected repository and the account can
apply them. The template footer marks the issue as skill-filed. Give your
partner the bundle path to attach through the browser after the issue exists.

Without `gh`, hand over a prefilled issue link. Select a named template only
after confirming it exists in the destination:

```
https://github.com/korggy/superpowers-gpt6/issues/new?title=<url-encoded title>&body=<url-encoded body>
```

GitHub rejects URLs over about 8,000 characters; past that, send the link
with the title only and tell your partner to paste the body from the file.
