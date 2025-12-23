#!/bin/bash

# Script to deploy AI rules to Cursor rules directory structure
# Usage: ./deploy-rules.sh <filename> [filename2] [filename3] ...
# Example: ./deploy-rules.sh nextjs
# Example: ./deploy-rules.sh nextjs python

set -e

# Check if at least one filename argument is provided
if [ -z "$1" ]; then
    echo "Error: No filename provided"
    echo "Usage: ./deploy-rules.sh <filename> [filename2] [filename3] ..."
    echo "Example: ./deploy-rules.sh nextjs"
    echo "Example: ./deploy-rules.sh nextjs python"
    exit 1
fi

DIST_DIR="dist"
CURSOR_RULES_DIR="${DIST_DIR}/.cursor/rules"
TEMP_FILE="${DIST_DIR}/temp_combined.md"

# Function to extract description from markdown file (first heading)
extract_description() {
    local file="$1"
    # Extract the first line that starts with # and remove the # prefix and any leading/trailing whitespace
    local title=$(head -n 1 "$file" | sed 's/^# *//' | sed 's/ *$//')
    if [ -z "$title" ]; then
        # Fallback to filename if no title found
        basename "$file" .md
    else
        echo "$title"
    fi
}

# Function to escape YAML string (escape quotes and backslashes)
escape_yaml_string() {
    local str="$1"
    # Escape backslashes first, then double quotes
    echo "$str" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
}

# Clear and recreate dist directory
echo "Clearing dist directory..."
rm -rf "$DIST_DIR"
mkdir -p "$CURSOR_RULES_DIR"
mkdir -p "${DIST_DIR}/.github"

# Process each rule file
echo "Processing rule files..."
FIRST_FILE=true
for FILENAME in "$@"; do
    SOURCE_FILE="rules/${FILENAME}.md"
    
    # Check if source file exists
    if [ ! -f "$SOURCE_FILE" ]; then
        echo "Error: Source file '${SOURCE_FILE}' not found"
        rm -rf "$DIST_DIR"
        exit 1
    fi
    
    # Extract description from the first heading
    DESCRIPTION=$(extract_description "$SOURCE_FILE")
    ESCAPED_DESCRIPTION=$(escape_yaml_string "$DESCRIPTION")
    
    # Create rule directory
    RULE_DIR="${CURSOR_RULES_DIR}/${FILENAME}"
    mkdir -p "$RULE_DIR"
    
    # Create RULE.md with frontmatter and content
    RULE_FILE="${RULE_DIR}/RULE.md"
    
    # Write frontmatter
    cat > "$RULE_FILE" <<EOF
---
description: "$ESCAPED_DESCRIPTION"
globs: []
alwaysApply: true
---

EOF
    
    # Append the original content (skip the first line if it's a heading, or include it)
    # We'll include all content as-is since the frontmatter is separate
    cat "$SOURCE_FILE" >> "$RULE_FILE"
    
    echo "  ✓ Created rule: ${RULE_FILE}"
    
    # Also add to combined file for GitHub Copilot instructions
    if [ "$FIRST_FILE" = true ]; then
        FIRST_FILE=false
        cat "$SOURCE_FILE" > "$TEMP_FILE"
    else
        echo "" >> "$TEMP_FILE"
        echo "---" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        cat "$SOURCE_FILE" >> "$TEMP_FILE"
    fi
done

# Deploy to GitHub Copilot instructions
echo "Deploying rules to ${DIST_DIR}/.github/copilot-instructions.md..."
mv "$TEMP_FILE" "${DIST_DIR}/.github/copilot-instructions.md"

echo ""
echo "✓ Successfully deployed rules to:"
echo "  - ${CURSOR_RULES_DIR}/ (Cursor rules directory structure)"
for FILENAME in "$@"; do
    echo "    - ${FILENAME}/RULE.md"
done
echo "  - ${DIST_DIR}/.github/copilot-instructions.md"

