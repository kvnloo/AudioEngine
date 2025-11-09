#!/bin/bash

# Simple documentation build script that doesn't require Swift compilation
# This works around Swift 3.0 compatibility issues

echo "Building documentation without compilation..."

# Install jazzy if not present
if ! command -v jazzy &> /dev/null; then
    echo "Installing Jazzy..."
    gem install jazzy
fi

# Find jazzy in gem path if not in PATH
JAZZY_CMD=$(command -v jazzy || find ~/.gem -name jazzy -type f -executable 2>/dev/null | head -1 || echo "jazzy")

# If still not found, try the GitHub Actions path
if [ ! -x "$JAZZY_CMD" ]; then
    JAZZY_CMD=$(find /Users/runner -name jazzy -type f -executable 2>/dev/null | head -1 || echo "jazzy")
fi

echo "Using jazzy from: $JAZZY_CMD"

# Create documentation using jazzy with minimal requirements
$JAZZY_CMD \
  --clean \
  --author "Kevin" \
  --author_url "https://github.com/kvnloo" \
  --github_url "https://github.com/kvnloo/PhaseIWireframe" \
  --module "Phase_1_Wireframe" \
  --root_url "https://kvnloo.github.io/PhaseIWireframe/" \
  --output docs \
  --theme fullwidth \
  --source-directory "Phase 1 Wireframe" \
  --exclude "*/Pods/*" \
  --swift-version 5.0 \
  --skip-xcodebuild

echo "Documentation build complete!"