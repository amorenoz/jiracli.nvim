#!/bin/bash
# nvim-editor-wrapper.sh - Wrapper script for jcli editor integration
# Usage: nvim-editor-wrapper.sh -t|--tmp-dir <dir> <file>

set -e

# Default values
TMP_DIR=""
COMMENT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--tmp-dir)
      TMP_DIR="$2"
      shift 2
      ;;
    *)
      COMMENT_FILE="$1"
      shift
      ;;
  esac
done

# Validate required parameters
if [[ -z "$TMP_DIR" ]]; then
  echo "Error: -t|--tmp-dir parameter is required" >&2
  exit 1
fi

if [[ -z "$COMMENT_FILE" ]]; then
  echo "Error: Comment file parameter is required" >&2
  exit 1
fi

# Set up file paths
MARKER_FILE="$TMP_DIR/nvim_ready"
NVIM_COMMENT_FILE="$TMP_DIR/comment.tmp"

# Copy the file to our known location so Neovim can open it
cp "$COMMENT_FILE" "$NVIM_COMMENT_FILE"

# Signal Neovim that the file is ready
touch "$MARKER_FILE"

# Wait for Neovim to signal it's done (marker file removed)
while [ -f "$MARKER_FILE" ]; do
  sleep 0.1
done

# Copy the edited content back
cp "$NVIM_COMMENT_FILE" "$COMMENT_FILE"
