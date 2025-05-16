#!/bin/bash

# Define installation path
POSTMAN_DIR="$HOME/goinfre/postman"
POSTMAN_TAR_URL="https://dl.pstmn.io/download/latest/linux64"
POSTMAN_TAR="$POSTMAN_DIR/postman.tar.gz"

# Create directory
mkdir -p "$POSTMAN_DIR"
cd "$POSTMAN_DIR" || exit 1

# Download Postman
echo "📦 Downloading Postman..."
curl -L "$POSTMAN_TAR_URL" -o "$POSTMAN_TAR"

# Extract it
echo "📂 Extracting..."
tar -xzf "$POSTMAN_TAR"
rm "$POSTMAN_TAR"

# Create a symlink (optional)
ln -s "$POSTMAN_DIR/Postman/Postman" "$POSTMAN_DIR/postman"

# Run Postman
echo "🚀 Launching Postman..."
"$POSTMAN_DIR/postman" &

echo "✅ Done. Postman is running from: $POSTMAN_DIR"

