#!/bin/sh

echo "### $0"

DIR=$(dirname $0)
cd $DIR

echo "DIR: $DIR"
pwd

export LANG=en_US.UTF-8

git submodule update --init --recursive
pod install

/usr/bin/xcodebuild build -scheme CoPilot -workspace CoPilot.xcworkspace
