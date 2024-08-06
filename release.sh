#!/bin/bash

# Define Variables
GDBIN="./Godot_v4.3-beta3_linux.x86_64"
PEAR=$(which pear)
BUILD_PATH="build/"
GAME_PATH="game/"
JS_PATH="core/"

if [ -z "$PEAR" ]; then
  echo "'pear' command not found"
  echo "npm i -g pear"
  exit 1
fi

# Check for at least one argument and a valid channel
if [ -z "$1" ]; then
    echo "Usage: $0 <flags> <channel='dev'>"
    echo "Flags:"
    echo "  b - Build Godot project"
    echo "  d - run Pears devel mode"
    echo "  p - Apply patches"
    echo "  k - Build Kernel"
    echo "  s - Seed project"
    echo "  r - Stage and release (requires channel: dev or production)"
    echo "Example: $0 bpr dev"
    exit 1
fi

CHANNEL="$2"  # Explicitly set the channel based on the second argument
if [ -z $CHANNEL ]; then
  CHANNEL='dev'
fi

i=0
while [ $i -lt ${#1} ]; do
    flag=${1:$i:1}
    case $flag in
        b)
            echo "Preparing Pears Env..."
            rm -rf $BUILD_PATH && mkdir $BUILD_PATH
            cat package.json.runtime > $BUILD_PATH/package.json
            cat bootloader.js > $BUILD_PATH/bootloader.js
            cd $BUILD_PATH && npm i
            cd -
            echo "Building Godot project..."
            cd $GAME_PATH && ../$GDBIN --export-release Web --headless
            cd -
            ;;
        d)
            echo "Running Pears"
            cd $BUILD_PATH \
              && exec $PEAR run --dev .
            ;;
        p)
            echo "Applying patches..."
            patch $BUILD_PATH/index.js --no-backup-if-mismatch < pearsgodot_index.js.patch
            ;;
        s)
            echo "Seeding project..."
            cd $BUILD_PATH
            $PEAR seed $CHANNEL
            cd -
            ;;
        r)
            echo "Handling $CHANNEL channel staging and release..."
            cd $BUILD_PATH \
              && $PEAR stage $CHANNEL && $PEAR release $CHANNEL
            cd -
            ;;
        k)
            echo "Building kernel"
            cd $JS_PATH && yarn build
            cd - && cat bootloader.js > $BUILD_PATH/bootloader.js
            ;;
        *)
            echo "Invalid option: $flag" >&2
            ;;
    esac
    i=$((i + 1))
done

echo "Operations completed."
