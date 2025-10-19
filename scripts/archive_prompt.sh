#!/bin/bash

# 📦 Automatic prompt archiving script
# Usage: ./scripts/archive_prompt.sh feature-XX-name

set -e

# Colors for messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verify arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: You must specify the feature slug${NC}"
    echo "Usage: ./scripts/archive_prompt.sh feature-XX-name"
    exit 1
fi

FEATURE_SLUG=$1
PROMPT_DIR=".prompts/${FEATURE_SLUG}"
OUTPUT_DIR="${PROMPT_DIR}/output"

# Verify prompt folder exists
if [ ! -d "$PROMPT_DIR" ]; then
    echo -e "${RED}❌ Error: Folder ${PROMPT_DIR} does not exist${NC}"
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}📦 Archiving feature: ${FEATURE_SLUG}${NC}"
echo ""

# Create metadata file
echo ""
echo -e "${BLUE}📋 Creating metadata${NC}"
cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "feature_slug": "$FEATURE_SLUG",
  "archived_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "archived_by": "$(git config user.name || echo 'Unknown')",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'Not a git repository')",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'Unknown')"
}
EOF
echo -e "${GREEN}✓${NC} Metadata created: $OUTPUT_DIR/metadata.json"

# Generate summary
echo ""
echo -e "${BLUE}📊 Archiving Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Feature      : ${GREEN}$FEATURE_SLUG${NC}"
echo -e "Destination  : ${GREEN}$OUTPUT_DIR${NC}"
echo -e "Files        : ${GREEN}$(find "$OUTPUT_DIR" -type f | wc -l | xargs)${NC}"
echo -e "Size         : ${GREEN}$(du -sh "$OUTPUT_DIR" | cut -f1)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Archive structure
echo ""
echo -e "${BLUE}📁 Archive Structure${NC}"
find "$OUTPUT_DIR" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'

echo ""
echo -e "${GREEN}✅ Archiving completed successfully!${NC}"

