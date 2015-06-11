#!/bin/sh

DIR=$(dirname "$0")
cd $DIR

export LANG=en_US.UTF-8

git submodule update --init --recursive
pod install

/usr/bin/xcodebuild build -scheme CoPilot -workspace CoPilot.xcworkspace
