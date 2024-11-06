#!/bin/bash

# Help message
show_usage() {
    echo "Usage: $0 <watch_directory>"
    echo "Watches the specified directory for changes in Swift and Markdown files"
    echo "and automatically rebuilds DocC documentation to ./public directory"
    exit 1
}

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    show_usage
fi

# Configuration
WATCH_DIR="$1"  # Use the provided directory
TEMP_DIR=$(mktemp -d)
OUTPUT_DIR="./public"
BUILD_CMD="xcodebuild docbuild -scheme DataThespian -derivedDataPath $TEMP_DIR"
PORT=8000

# Global variables for process management
SERVER_PID=""
FSWATCH_PID=""

# Cleanup function for all processes and temporary directory
cleanup() {
    echo -e "\nCleaning up..."
    
    # Kill the Python server
    if [ ! -z "$SERVER_PID" ]; then
        echo "Stopping web server (PID: $SERVER_PID)..."
        kill -9 "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
    fi
    
    # Kill fswatch
    if [ ! -z "$FSWATCH_PID" ]; then
        echo "Stopping file watcher (PID: $FSWATCH_PID)..."
        kill -9 "$FSWATCH_PID" 2>/dev/null
        wait "$FSWATCH_PID" 2>/dev/null
    fi
    
    # Kill any remaining Python servers on our port (belt and suspenders)
    local remaining_servers=$(lsof -ti:$PORT)
    if [ ! -z "$remaining_servers" ]; then
        echo "Cleaning up remaining processes on port $PORT..."
        kill -9 $remaining_servers 2>/dev/null
    fi
    
    echo "Removing temporary directory..."
    rm -rf "$TEMP_DIR"
    
    echo "Cleanup complete"
    exit 0
}

# Register cleanup function for multiple signals
trap cleanup EXIT INT TERM

# Validate watch directory
if [ ! -d "$WATCH_DIR" ]; then
    echo "Error: Directory '$WATCH_DIR' does not exist"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check for required tools
if ! command -v fswatch >/dev/null 2>&1; then
    echo "Error: This script requires fswatch on macOS."
    echo "Install it using: brew install fswatch"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: This script requires python3 for the web server."
    exit 1
fi

# Function to find the .doccarchive file
find_doccarchive() {
    local archive_path=$(find "$TEMP_DIR" -name "*.doccarchive" -type d | head -n 1)
    if [ -z "$archive_path" ]; then
        echo "Error: Could not find .doccarchive file"
        return 1
    fi
    echo "$archive_path"
}

# Function to start the web server
start_server() {
    # Check if something is already running on the port
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "Port $PORT is already in use. Attempting to clean up..."
        kill -9 $(lsof -ti:$PORT) 2>/dev/null
        sleep 1
    fi
    
    echo "Starting web server on http://localhost:$PORT ..."
    cd "$OUTPUT_DIR" && python3 -m http.server $PORT &
    SERVER_PID=$!
    cd - > /dev/null
    
    # Wait a moment to ensure server starts
    sleep 1
    
    # Verify server started successfully
    if ! lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "Failed to start web server"
        exit 1
    fi
    
    echo "Documentation is now available at: http://localhost:$PORT"
}

# Function to rebuild documentation
rebuild_docs() {
    echo "Changes detected in: $1"
    echo "Rebuilding documentation..."
    
    # Clean temporary directory contents while preserving the directory
    rm -rf "$TEMP_DIR"/*
    
    # Build documentation
    eval "$BUILD_CMD"
    if [ $? -ne 0 ]; then
        echo "Error building documentation"
        return 1
    fi
    
    # Find the .doccarchive file
    local archive_path=$(find_doccarchive)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Process the archive for static hosting
    echo "Processing documentation for static hosting..."
    $(xcrun --find docc) process-archive \
        transform-for-static-hosting "$archive_path" \
        --output-path "$OUTPUT_DIR" \
        --hosting-base-path "/"
        
    if [ $? -eq 0 ]; then
        echo "Documentation rebuilt successfully at $(date '+%H:%M:%S')"
        echo "Documentation available at: http://localhost:$PORT"
    else
        echo "Error processing documentation archive"
    fi
}

# Initial build
echo "Performing initial documentation build..."
echo "Watching directory: $WATCH_DIR"
echo "Output directory: $OUTPUT_DIR"
rebuild_docs "initial build"

# Start the web server after initial build
start_server

# Watch for changes
echo "Watching for changes in Swift and Markdown files..."
fswatch -r "$WATCH_DIR" | while read -r file; do
    if [[ "$file" =~ \.(swift|md)$ ]] || [[ "$file" =~ \.docc/ ]]; then
        rebuild_docs "$file"
    fi
done &
FSWATCH_PID=$!

# Wait for fswatch to exit (which should only happen if there's an error)
wait $FSWATCH_PID
