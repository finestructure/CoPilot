#!/bin/sh

DIR=$(dirname "$0")
cd "$DIR"

# use binary install for alcatraz until the build script below works when run from Alcatraz

./install.sh

# below is work in progress

# export LANG=en_US.UTF-8
#
# git submodule update --init --recursive
# pod install
#
# /usr/bin/xcodebuild build -scheme CoPilot -workspace CoPilot.xcworkspace
