# Multi-Agent Code Review Skill

A [Claude Code](https://claude.ai/code) skill that runs parallel code reviews using multiple AI agents via [Cursor CLI](https://cursor.com/cli), then synthesizes results into a comprehensive report.

## Why?

Different AI models catch different issues. By running the same review prompt against multiple agents and combining their findings, you get more thorough coverage than any single model provides.

## Quick Start

### Installation

```bash
# Clone into your project's skills directory
git clone https://github.com/ktaletsk/multi-agent-code-review-skill.git .claude/skills/multi-agent-code-review

# Or install globally
git clone https://github.com/ktaletsk/multi-agent-code-review-skill.git ~/.claude/skills/multi-agent-code-review
```

### Usage

In Claude Code, simply say:

```
Review my staged changes
```

Or explicitly invoke:

```
/skill:multi-agent-code-review
```

Or run manually:

```
Run the multi-agent code review skill
```

## How It Works

1. **Parallel Execution**: Spawns multiple `cursor-agent` processes simultaneously, each using a different AI model in read-only mode
2. **Independent Reviews**: Each agent reviews the staged git changes without seeing other agents' outputs
3. **Synthesis**: Claude Code reads all outputs and combines them into a single deduplicated report

## Configuration

### Change Agents/Models

Edit `scripts/run-reviews.sh`:

```bash
MODELS=(
  "gpt-5.2-high"
  "grok"
  "opus-4.5"
  "gemini-3-pro"
)
```

Run `cursor-agent --list-models` for available options.

### Change Review Focus

Edit `prompts/review-prompt.md` to adjust:
- What aspects to focus on (security, performance, etc.)
- Output format
- How critical the review should be

### Add Thinking Depth

Add keywords to `prompts/review-prompt.md` for deeper analysis:
- `think` - basic reasoning
- `think hard` - more thorough
- `think harder` - very thorough
- `ultrathink` - maximum depth (slower)

## Output

After running, you'll find in `output/`:
- `review_*.json` - Individual agent results
- `COMBINED_REVIEW.md` - Synthesized report with:
  - Deduplicated issues by severity (HIGH/MEDIUM/LOW)
  - File locations and line numbers
  - Specific recommendations
  - Overall verdict

## Requirements

- [Cursor CLI](https://cursor.com/cli) (`cursor-agent`) installed and authenticated
- Active Cursor subscription
- Claude Code for synthesis

## Files

```
multi-agent-code-review-skill/
├── SKILL.md              # Skill definition for Claude Code
├── README.md             # This file
├── scripts/
│   └── run-reviews.sh    # Parallel review runner
├── prompts/
│   └── review-prompt.md  # Review prompt template
└── output/               # Results (gitignored)
```

## License

MIT
