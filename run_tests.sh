#!/bin/bash

# Simple script to run Godot tests
# Expects GODOT environment variable to contain path to Godot executable

if [ -z "$GODOT" ]; then
    echo "Error: GODOT environment variable not set"
    echo "Please set GODOT to the path of your Godot executable"
    echo "Example: export GODOT=/path/to/godot"
    exit 1
fi

if [ ! -x "$GODOT" ]; then
    echo "Error: Godot executable not found or not executable at: $GODOT"
    exit 1
fi

echo "Running tests with Godot at: $GODOT"
"$GODOT" -d -s --path "$PWD" tests/test_runner.gd