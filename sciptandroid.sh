#!/bin/bash

# Define directories and file paths
USER=$(whoami)
GOINFRE_DIR="/goinfre/$USER"
SDK_DIR="$GOINFRE_DIR/Android/Sdk"
CMDLINE_TOOLS_ZIP="$GOINFRE_DIR/commandlinetools-linux-7302050_latest.zip"
CMDLINE_TOOLS_DIR="$SDK_DIR/cmdline-tools"
ANDROID_STUDIO_ZIP="$GOINFRE_DIR/android-studio-2023.1.1.21-linux.tar.gz"
ANDROID_STUDIO_DIR="$GOINFRE_DIR/android-studio"
JAVA_TAR="$GOINFRE_DIR/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz"
JAVA_DOWNLOAD_URL="https://objects.githubusercontent.com/github-production-release-asset-2e65be/602574963/c476bbc2-f181-4954-877b-d60e0fd6336b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250302%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250302T015024Z&X-Amz-Expires=300&X-Amz-Signature=62bb03dfaf829f9fe1bfae50fc7faca9374350c89c55322fba52e8313535ca0c&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DOpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz&response-content-type=application%2Foctet-stream"

# Download link for cmdline-tools
CMDLINE_TOOLS_DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip"

# Ensure directories exist
mkdir -p "$SDK_DIR"
mkdir -p "$CMDLINE_TOOLS_DIR"
mkdir -p "$ANDROID_STUDIO_DIR"

# Set environment variables
export ANDROID_SDK_ROOT="$SDK_DIR"
export ANDROID_HOME="$SDK_DIR"  # For backward compatibility
export ANDROID_AVD_HOME="$GOINFRE_DIR/.android/avd"  # AVDs will be stored here
mkdir -p "$ANDROID_AVD_HOME"

# Suppress Qt warnings
export QT_LOGGING_RULES="*.warning=false"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Download cmdline-tools if not already downloaded
if [ ! -f "$CMDLINE_TOOLS_ZIP" ]; then
    echo "Downloading cmdline-tools..."
    wget -O "$CMDLINE_TOOLS_ZIP" "$CMDLINE_TOOLS_DOWNLOAD_URL" || handle_error "Failed to download cmdline-tools."
    echo "cmdline-tools downloaded successfully."
fi

# Install Android Studio if not installed
if [ ! -d "$ANDROID_STUDIO_DIR" ]; then
    echo "Extracting Android Studio..."
    tar -xvzf "$ANDROID_STUDIO_ZIP" -C "$ANDROID_STUDIO_DIR" --strip-components=1 || handle_error "Failed to extract Android Studio."
    echo "Android Studio extracted successfully."
else
    echo "Android Studio is already installed."
fi

# Ensure cmdline-tools is installed
if [ ! -d "$CMDLINE_TOOLS_DIR/latest" ]; then
    echo "Extracting cmdline-tools..."
    unzip -q "$CMDLINE_TOOLS_ZIP" -d "$CMDLINE_TOOLS_DIR" || handle_error "Failed to extract cmdline-tools."
    # Move the contents to the correct directory structure
    mv "$CMDLINE_TOOLS_DIR/cmdline-tools" "$CMDLINE_TOOLS_DIR/latest" || handle_error "Failed to move cmdline-tools."
    echo "cmdline-tools extracted successfully."
else
    echo "cmdline-tools already extracted."
fi

# Download OpenJDK if not already downloaded
if [ ! -f "$JAVA_TAR" ]; then
    echo "OpenJDK tar file does not exist. Downloading OpenJDK..."
    wget -O "$JAVA_TAR" "$JAVA_DOWNLOAD_URL" || handle_error "Failed to download OpenJDK."
    echo "OpenJDK downloaded successfully."
fi

# Extract OpenJDK if not already extracted
if [ ! -d "$SDK_DIR/jdk" ]; then
    echo "Extracting OpenJDK..."
    mkdir -p "$SDK_DIR/jdk"
    tar -xvzf "$JAVA_TAR" -C "$SDK_DIR/jdk" || handle_error "Failed to extract OpenJDK."
    echo "OpenJDK extracted successfully."
fi

# Set JAVA_HOME and update PATH
export JAVA_HOME="$SDK_DIR/jdk/jdk-21.0.6+7"
export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
java -version || handle_error "Java installation verification failed."

# Install SDK packages
echo "Installing SDK packages..."
yes | "$CMDLINE_TOOLS_DIR/latest/bin/sdkmanager" --sdk_root="$SDK_DIR" "platform-tools" "platforms;android-30" "build-tools;30.0.3" || handle_error "SDK package installation failed."
echo "SDK packages installed successfully."

# Ensure system images are installed for the AVD (Android Virtual Device)
echo "Installing system image for AVD..."
"$CMDLINE_TOOLS_DIR/latest/bin/sdkmanager" --sdk_root="$SDK_DIR" "system-images;android-30;google_apis_playstore;x86_64" || handle_error "Failed to install system image."
echo "System image installed successfully."

# Create Android Virtual Device (AVD)
AVD_NAME="Pixel_4_API_30"
if ! "$SDK_DIR/emulator/emulator" -list-avds | grep -q "$AVD_NAME"; then
    echo "Creating Android Virtual Device (AVD)..."
    "$CMDLINE_TOOLS_DIR/latest/bin/avdmanager" create avd --name "$AVD_NAME" --package "system-images;android-30;google_apis_playstore;x86_64" --device "pixel_4" --force || handle_error "Failed to create AVD."
    echo "AVD created successfully."
else
    echo "AVD '$AVD_NAME' already exists."
fi

# Fix shared memory issue with the emulator by specifying a different temp location
echo "Setting alternate temp directory to avoid shared memory issues..."
export JAVA_OPTS="-Djava.io.tmpdir=$GOINFRE_DIR/tmp"
mkdir -p "$GOINFRE_DIR/tmp"

# Start the Android Emulator with software rendering
echo "Starting the Android Emulator with software rendering..."
export ANDROID_EMULATOR_USE_SOFTWARE_GPU=1
"$SDK_DIR/emulator/emulator" -avd "$AVD_NAME" -gpu swiftshader_indirect &

# Wait for the emulator to start
echo "Waiting for the emulator to start..."
sleep 60  # You can adjust the sleep time as needed

echo "Android Emulator started successfully."