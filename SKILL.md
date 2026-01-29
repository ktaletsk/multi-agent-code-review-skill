---
name: Multi-Agent Code Review
description: Run parallel code reviews using multiple AI agents via Cursor CLI, then synthesize results into a comprehensive report. Use when asked to review code, review changes, or run a code review.
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

## Workflow

### Step 1: Run Parallel Reviews

Execute the review script to spawn parallel Cursor CLI agents:

```bash
./scripts/run-reviews.sh
```

This will:
- Run 4 agents in parallel (configurable in the script)
- Save individual JSON results to `./output/`
- Take 1-3 minutes depending on code size

### Step 2: Synthesize Results

After the script completes, read all JSON files in the output directory and synthesize them into a combined report.

**Synthesis Rules:**
1. Do NOT mention which agent found which issue
2. Deduplicate similar issues (same file + same line + same problem = one entry)
3. If reviewers disagree on severity, use the higher severity
4. Preserve unique findings from each reviewer
5. Present findings as if from a single thorough review

**Output Format:**

Write the combined report to `./output/COMBINED_REVIEW.md` using this structure:

```markdown
# Code Review Report

**Repository:** [repo name]
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

### Step 3: Report to User

After writing the combined report, summarize the key findings for the user:
- Total issues found (by severity)
- Top 3 priority items to address
- Overall verdict

## Customization

The user can customize:
- **Agents/Models**: Edit `scripts/run-reviews.sh` → `MODELS` array
- **Review focus**: Edit `prompts/review-prompt.md`
- **Thinking depth**: Add "think hard" or "ultrathink" to the prompt

## Files

```
multi-agent-code-review-skill/
├── SKILL.md              # This file
├── scripts/
│   └── run-reviews.sh    # Parallel review runner
├── prompts/
│   └── review-prompt.md  # Review prompt template
└── output/               # Results directory
    ├── review_*.json     # Individual agent outputs
    └── COMBINED_REVIEW.md
```

## Installation

### Option 1: Project-local (recommended)
```bash
# Clone into your project's .claude/skills/ directory
git clone https://github.com/ktaletsk/multi-agent-code-review-skill.git .claude/skills/multi-agent-code-review
```

### Option 2: Global
```bash
# Clone to global skills directory
git clone https://github.com/ktaletsk/multi-agent-code-review-skill.git ~/.claude/skills/multi-agent-code-review
```

## Requirements

- Cursor CLI (`cursor-agent`) installed and authenticated
- Active Cursor subscription with access to desired models
- Claude Code for synthesis step
