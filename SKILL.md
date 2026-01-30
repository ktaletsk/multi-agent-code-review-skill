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

## CRITICAL: Working Directory

**The review must run in the USER'S PROJECT DIRECTORY, not in this skill's directory.**

Before running anything, determine the user's project directory by:
1. Checking where the user started their Claude Code session
2. Looking for their project's git root
3. This is typically NOT `/Users/.../skills/multi-agent-code-review/`

## Workflow

### Step 1: Identify the Target Repository

First, determine the user's current working directory (the repo to review):

```bash
pwd
```

Confirm this is the correct repository (should have staged git changes to review).

### Step 2: Run Parallel Reviews

Run the review script FROM THE USER'S PROJECT DIRECTORY:

```bash
~/.claude/skills/multi-agent-code-review/scripts/run-reviews.sh
```

**IMPORTANT**: Run this command from the user's project directory, NOT from the skill directory. The script will automatically detect and use the current working directory.

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
