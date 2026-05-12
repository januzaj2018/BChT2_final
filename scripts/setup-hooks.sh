#!/bin/bash

# Setup pre-commit hooks
# Run this after cloning the repository

HOOKS_DIR=".git/hooks"
GITHOOKS_DIR=".githooks"

echo "Setting up git hooks..."

# Create hooks symlink or copy
if [ -d "$GITHOOKS_DIR" ]; then
    for hook in $GITHOOKS_DIR/*; do
        if [ -f "$hook" ]; then
            hook_name=$(basename "$hook")
            hook_path="$HOOKS_DIR/$hook_name"
            
            if [ -f "$hook_path" ]; then
                echo "WARNING: $hook_name already exists. Skipping..."
            else
                cp "$hook" "$hook_path"
                chmod +x "$hook_path"
                echo "Installed $hook_name"
            fi
        fi
    done
else
    echo "ERROR: .githooks directory not found"
    exit 1
fi

echo "Git hooks setup complete"
