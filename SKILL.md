---
name: multi-agent-code-review
description: Run parallel code reviews with multiple AI agents, then synthesize into one report. Triggers on "review code" or "multi-agent review".
---

# Multi-Agent Code Review Skill

This skill runs the same code review prompt against multiple AI agents in parallel using Cursor CLI, then synthesizes their findings into a single comprehensive report.

## When to Use

Activate this skill when the user asks to:
- "Review my code"
- "Run a code review"
- "Review the staged changes"
- "Do a multi-agent review"
- "Get multiple perspectives on this code"

## CRITICAL: Target Directory

**You must pass the USER'S PROJECT DIRECTORY as an argument to the script.**

The user's project directory is where they started their Claude Code session - NOT this skill's directory. Look for the git repository path in the conversation context (e.g., `/Users/.../git/jupyter_server`).

## Workflow

### Step 1: Identify the Target Repository

Determine the user's project directory from the conversation context. This is typically shown at the start of the session or can be found by checking where CLAUDE.md is located. It is NOT `/Users/.../skills/multi-agent-code-review/`.

### Step 2: Run Parallel Reviews

Run the review script and **pass the user's project directory as an argument**:

```bash
~/.claude/skills/multi-agent-code-review/scripts/run-reviews.sh /path/to/users/project
```

For example, if the user is working in `/Users/ktaletskiy/git/jupyter_server`:
```bash
~/.claude/skills/multi-agent-code-review/scripts/run-reviews.sh /Users/ktaletskiy/git/jupyter_server
```

**IMPORTANT**: Always pass the full path to the user's project as the first argument.

This will:
- Run 4 agents in parallel (configurable in the script)
- Save individual JSON results to `~/.claude/skills/multi-agent-code-review/output/`
- Take 1-3 minutes depending on code size

### Step 3: Synthesize Results

After the script completes, read all JSON files from `~/.claude/skills/multi-agent-code-review/output/` and synthesize them into a combined report.

**Synthesis Rules:**
1. Do NOT mention which agent found which issue
2. Deduplicate similar issues (same file + same line + same problem = one entry)
3. If reviewers disagree on severity, use the higher severity
4. Preserve unique findings from each reviewer
5. Present findings as if from a single thorough review

**Output Format:**

Write the combined report to `~/.claude/skills/multi-agent-code-review/output/COMBINED_REVIEW.md` using this structure:

```markdown
# Code Review Report

**Repository:** [repo name from user's directory]
**Date:** [today's date]

---

## Summary

[1-2 paragraph summary]

**Consensus:** [X of Y reviewers recommended changes / approved]

---

## Critical Issues (Require Action)

### 1. [Issue Title]
**Severity:** 🔴 HIGH
**File:** `path/to/file` (line X)

[Description]

**Recommendation:** [How to fix]

---

## Medium Issues (Should Address)

[Same format, 🟠 MEDIUM]

## Low Issues (Consider Addressing)

[Same format, 🟡 LOW]

## Suggested Improvements

[Numbered list]

---

## Verdict

**[🔴 REQUEST CHANGES / 🟢 APPROVE]**

[Priority action items table]
```

### Step 4: Report to User

After writing the combined report, summarize the key findings:
- Total issues found (by severity)
- Top 3 priority items to address
- Overall verdict

## Customization

The user can customize:
- **Agents/Models**: Edit `~/.claude/skills/multi-agent-code-review/scripts/run-reviews.sh` → `MODELS` array
- **Review focus**: Edit `~/.claude/skills/multi-agent-code-review/prompts/review-prompt.md`
- **Thinking depth**: Add "think hard" or "ultrathink" to the prompt

## Files

```
~/.claude/skills/multi-agent-code-review/
├── SKILL.md              # This file
├── scripts/
│   └── run-reviews.sh    # Parallel review runner
├── prompts/
│   └── review-prompt.md  # Review prompt template
└── output/               # Results directory
    ├── review_*.json     # Individual agent outputs
    └── COMBINED_REVIEW.md
```
