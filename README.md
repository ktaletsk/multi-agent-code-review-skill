# multi-agent-code-review

> **Ensemble code reviews.** Run the same review prompt against multiple AI 
> agents in parallel, then synthesize their findings into one comprehensive 
> report — because different models catch different bugs.

[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://code.claude.com/docs/en/skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Why This Exists

No single AI model catches everything. GPT might spot a race condition that 
Opus misses, while Gemini flags a performance issue neither noticed. By running 
the same critical review prompt against multiple agents and combining their 
findings, you get more thorough coverage than any single model provides.

| | Single Model Review | multi-agent-code-review |
|---|---|---|
| One perspective | ✅ | ❌ Multiple perspectives |
| Model-specific blind spots | 😬 | ❌ Cross-validated findings |
| Fast | ✅ | ❌ Parallel but slower |
| Simple | ✅ | ❌ Requires Cursor CLI |

## How It Works

1. **Parallel Execution** — Spawns multiple `cursor-agent` processes simultaneously
2. **Independent Reviews** — Each agent reviews staged git changes in read-only mode
3. **Synthesis** — Claude Code combines outputs into a single deduplicated report

### Default Models

- `opus-4.5-thinking` — Anthropic's strongest reasoning model
- `gpt-5.2-high` — OpenAI with high thinking effort
- `gemini-3-pro` — Google's flagship model

## Installation

### Personal skill (all projects)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/ktaletsk/multi-agent-code-review ~/.claude/skills/multi-agent-code-review
```

### Project skill (specific project)

```bash
mkdir -p .claude/skills
git clone https://github.com/ktaletsk/multi-agent-code-review .claude/skills/multi-agent-code-review
```

## Requirements

- [Cursor CLI](https://cursor.com/cli) (`cursor-agent`) installed and authenticated
- Active Cursor subscription
- Claude Code for synthesis

## Usage

Start a code review:

```
/multi-agent-code-review
```

Or trigger naturally:

```
Review my staged changes
```

```
Run a multi-agent review
```

## Example Session

```
You: /multi-agent-code-review

Claude: I'll run parallel code reviews using multiple AI agents.

Running reviews on /Users/you/project...

  ⏳ Starting: opus-4.5-thinking
  ⏳ Starting: gpt-5.2-high
  ⏳ Starting: gemini-3-pro

Waiting for reviews to complete (this may take 1-3 minutes)...

  ✓ Completed: opus-4.5-thinking
  ✓ Completed: gpt-5.2-high
  ✓ Completed: gemini-3-pro

Now synthesizing results...

# Code Review Report

## Summary
The changes introduce timestamp handling improvements with proper 
fallback logic. All 3 reviewers found issues worth addressing.

## Critical Issues
None identified.

## Medium Issues
### 1. Pre-1970 timestamp edge case
**File:** `filemanager.py` (line 60)
Negative timestamps (valid for pre-1970 dates) are treated as invalid...

[continued...]
```

## Output

Results are saved to your project's `.reviews/` directory:

```
<your-project>/.reviews/
├── review_opus-4.5-thinking.json
├── review_gpt-5.2-high.json
├── review_gemini-3-pro.json
└── COMBINED_REVIEW.md
```

## Customization

### Change Models

Edit `scripts/run-reviews.sh`:

```bash
MODELS=(
  "opus-4.5-thinking"
  "gpt-5.2-high"
  "gemini-3-pro"
)
```

Run `cursor-agent --list-models` for available options.

### Change Review Focus

Edit `prompts/review-prompt.md` to adjust:
- What aspects to focus on (security, performance, etc.)
- Output format
- How critical the review should be

### Thinking Depth

Add keywords to `prompts/review-prompt.md`:
- `think` — basic reasoning
- `think hard` — more thorough  
- `think harder` — very thorough
- `ultrathink` — maximum depth (slower)

## Files

```
multi-agent-code-review/
├── SKILL.md              # Skill definition for Claude Code
├── README.md             # This file
├── scripts/
│   └── run-reviews.sh    # Parallel review runner
└── prompts/
    └── review-prompt.md  # Review prompt template
```

## Compatibility

This skill uses the open [Agent Skills](https://agentskills.io) standard and should work with:
- Claude Code (`~/.claude/skills/`)
- Cursor (`.cursor/skills/`)
- VS Code, GitHub Copilot, and other compatible agents

## License

MIT
