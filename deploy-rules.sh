#!/bin/bash

# Script to deploy AI rules to .cursorrules and GitHub Copilot instructions
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
TEMP_FILE="${DIST_DIR}/temp_combined.md"

# Clear and recreate dist directory
echo "Clearing dist directory..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/.github"

# Concatenate all source files
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
    
    # Add separator before all files except the first one
    if [ "$FIRST_FILE" = true ]; then
        FIRST_FILE=false
        cat "$SOURCE_FILE" > "$TEMP_FILE"
        echo "  ✓ Added: ${SOURCE_FILE}"
    else
        echo "" >> "$TEMP_FILE"
        echo "---" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        cat "$SOURCE_FILE" >> "$TEMP_FILE"
        echo "  ✓ Added: ${SOURCE_FILE}"
    fi
done

# Deploy to .cursorrules
echo "Deploying rules to ${DIST_DIR}/.cursorrules..."
mv "$TEMP_FILE" "${DIST_DIR}/.cursorrules"

# Deploy to GitHub Copilot instructions
echo "Deploying rules to ${DIST_DIR}/.github/copilot-instructions.md..."
cp "${DIST_DIR}/.cursorrules" "${DIST_DIR}/.github/copilot-instructions.md"

echo "✓ Successfully deployed rules to:"
echo "  - ${DIST_DIR}/.cursorrules"
echo "  - ${DIST_DIR}/.github/copilot-instructions.md"

