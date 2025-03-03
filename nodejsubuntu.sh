#!/bin/bash

# Define the Node.js version to install
NODE_VERSION="v18.17.1"  # Change this to your desired version
NODE_DIR="/goinfre/$USER/nodejs"  # Install Node.js in your Goinfre directory
NODE_TAR="node-$NODE_VERSION-linux-x64.tar.xz"  # Node.js tarball name
NODE_URL="https://nodejs.org/dist/$NODE_VERSION/$NODE_TAR"  # Node.js download URL
NODE_BIN="$NODE_DIR/node-$NODE_VERSION-linux-x64/bin"  # Node.js binary directory

# Step 1: Create the Node.js directory in Goinfre
echo "Creating Node.js directory in Goinfre..."
mkdir -p "$NODE_DIR"
cd "$NODE_DIR"

# Step 2: Download Node.js
echo "Downloading Node.js $NODE_VERSION..."
curl -O "$NODE_URL"

# Step 3: Extract the tarball
echo "Extracting Node.js..."
tar -xf "$NODE_TAR"

# Step 4: Add Node.js to PATH
echo "Adding Node.js to PATH..."

# Check if the PATH is already set
if [[ ":$PATH:" != *":$NODE_BIN:"* ]]; then
    # Add Node.js to PATH in .bashrc or .zshrc
    if [[ -f ~/.bashrc ]]; then
        echo "export PATH=\"$NODE_BIN:\$PATH\"" >> ~/.bashrc
        echo "Added Node.js to ~/.bashrc"
    fi
    if [[ -f ~/.zshrc ]]; then
        echo "export PATH=\"$NODE_BIN:\$PATH\"" >> ~/.zshrc
        echo "Added Node.js to ~/.zshrc"
    fi
else
    echo "Node.js is already in PATH."
fi

# Step 5: Reload the shell configuration
echo "Reloading shell configuration..."
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
elif [[ -f ~/.zshrc ]]; then
    source ~/.zshrc
fi

# Step 6: Verify the installation
echo "Verifying Node.js installation..."
node -v
npm -v

echo "Node.js and npm have been successfully installed in Goinfre!"