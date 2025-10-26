#!/bin/sh
# POSIX sh compatible script for AI-assisted commit messages

# Get the staged diff
DIFF_OUTPUT=$(git diff --cached)

# Build the prompt
PROMPT="You are a senior software engineer.

Suggest 5 commit messages based on the following diff:

\`\`\`diff
${DIFF_OUTPUT}
\`\`\`

**Criteria:**

1. **Format:** Follow the [Conventional Commits](https://www.conventionalcommits.org/) format: \`<type>(<scope>): <description>\`.
  - **API relevant changes:**
    - \`feat(<scope>)\`: Commits that add or remove a feature.
    - \`fix(<scope>)\`: Commits that fix a bug.
  - **Code and Performance:**
    - \`refactor(<scope>)\`: Commits that restructure code without changing behavior.
    - \`perf(<scope>)\`: Commits that improve performance (a subset of refactor).
  - **Other Types:**
    - \`style(<scope>)\`: Commits that involve formatting, white-space, etc.
    - \`test(<scope>)\`: Commits that add or correct tests.
    - \`docs(<scope>)\`: Commits that affect documentation only.
    - \`build(<scope>)\`: Commits that affect build tools, CI pipelines, dependencies, etc.
    - \`ops(<scope>)\`: Commits that affect infrastructure, deployment, etc.
    - \`chore(<scope>)\`: Miscellaneous commits (e.g., modifying \`.gitignore\`).

2. **Scope:** Always include a relevant scope.

**Examples:**

- feat: add email notifications on new direct messages
- feat(shopping cart): add the amazing button
- feat!: remove ticket list endpoint
- fix(api): handle empty message in request body
- fix(api): fix wrong calculation of request body checksum
- refactor: implement fibonacci number calculation as recursion
- perf: decrease memory footprint for determine unique visitors by using HyperLogLog
- style: remove empty line
- build(release): bump version to 1.0.0

**Output Template**

Follow this output template and ONLY output raw commit messages without spacing,
numbers, triple backtick, or any king of decorations. Just give the commit messages,
do not start with sentence like \"Here are the requested commit messages:\"

fix(app): add password regex pattern
test(unit): add new test cases
style: remove unused imports
refactor(pages): extract common code to \`utils/wait.ts\`

**Instructions:**

- Understand the changes in the diff and their impact.
- Generate 5 commit messages, ensuring clarity and relevance.
- Cover different scenarios without overlap.

Output only the 5 commit messages in the specified format."

# Run the pipeline
aichat --model openai:gpt-4o-mini "$PROMPT" |
  fzf --height 40% --border --ansi --preview "echo {}" --preview-window=up:wrap |
  while IFS= read -r commit_msg; do
    COMMIT_MSG_FILE=$(mktemp)
    echo "$commit_msg" >"$COMMIT_MSG_FILE"

    ${EDITOR:-vim} "$COMMIT_MSG_FILE"

    if [ -s "$COMMIT_MSG_FILE" ]; then
      git commit -F "$COMMIT_MSG_FILE"
    else
      echo "Commit message is empty, commit aborted."
    fi

    rm -f "$COMMIT_MSG_FILE"
  done
