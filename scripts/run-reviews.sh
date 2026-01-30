#!/bin/bash
# run-reviews.sh - Multi-agent parallel code review
#
# Usage: run-reviews.sh TARGET_DIR
#   TARGET_DIR: The directory/repository to review (REQUIRED)
#
# Spawns parallel cursor-agent instances with different models
# to review staged git changes in the target directory.
# Results are saved to TARGET_DIR/.reviews/

set -e

# TARGET_DIR is REQUIRED - must be passed as first argument
if [ -z "$1" ]; then
  echo "Error: TARGET_DIR is required"
  echo "Usage: run-reviews.sh /path/to/project"
  echo ""
  echo "The target directory must be the project you want to review,"
  echo "NOT the skill directory."
  exit 1
fi

TARGET_DIR="$1"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$TARGET_DIR/.reviews"
PROMPT_FILE="$SKILL_DIR/prompts/review-prompt.md"

# Models/Agents to use (customize as needed)
# Run `cursor-agent --list-models` for available options
MODELS=(
  "opus-4.5-thinking"
  "gpt-5.2-high"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           Multi-Agent Code Review                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for prompt file
if [ ! -f "$PROMPT_FILE" ]; then
  echo -e "${RED}Error: Review prompt not found at $PROMPT_FILE${NC}"
  exit 1
fi

# Check for cursor-agent
if ! command -v cursor-agent &> /dev/null; then
  echo -e "${RED}Error: cursor-agent not found. Install from https://cursor.com/cli${NC}"
  exit 1
fi

# Verify target directory exists and is a git repo
if [ ! -d "$TARGET_DIR/.git" ]; then
  echo -e "${YELLOW}Warning: $TARGET_DIR does not appear to be a git repository${NC}"
fi

# Setup output directory
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/review_*.json

echo "📋 Prompt: $PROMPT_FILE"
echo "📁 Output: $OUTPUT_DIR"
echo -e "📂 Target: ${GREEN}$TARGET_DIR${NC}"
echo "🤖 Agents: ${MODELS[*]}"
echo ""
echo "Starting parallel reviews..."
echo ""

# Read prompt
PROMPT="$(cat "$PROMPT_FILE")"

# Run all agents in parallel with TARGET_DIR as workspace
# --mode=plan: read-only, no edits allowed
# --force: allows shell commands (git diff)
PIDS=()
for model in "${MODELS[@]}"; do
  echo "  ⏳ Starting: $model"
  cursor-agent -p --mode=plan --force --workspace="$TARGET_DIR" --model="$model" "$PROMPT" \
    > "$OUTPUT_DIR/review_${model}.json" 2>&1 &
  PIDS+=($!)
done

echo ""
echo "Waiting for reviews to complete (this may take 1-3 minutes)..."
echo ""

# Wait for all processes
COMPLETED=0
FAILED=0
for i in "${!PIDS[@]}"; do
  if wait "${PIDS[$i]}"; then
    echo -e "  ${GREEN}✓${NC} Completed: ${MODELS[$i]}"
    COMPLETED=$((COMPLETED + 1))
  else
    echo -e "  ${RED}✗${NC} Failed: ${MODELS[$i]}"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

if [ $COMPLETED -eq 0 ]; then
  echo -e "${RED}All reviews failed.${NC}"
  exit 1
fi

echo -e "${GREEN}Done!${NC} $COMPLETED succeeded, $FAILED failed"
echo ""
echo "Results:"
for model in "${MODELS[@]}"; do
  if [ -s "$OUTPUT_DIR/review_${model}.json" ]; then
    echo "  - $OUTPUT_DIR/review_${model}.json"
  fi
done
echo ""
