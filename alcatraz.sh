#!/bin/sh

DIR=$(dirname $0)
cd $DIR

git submodule update --init --recursive
pod install

/usr/bin/xcodebuild build -scheme CoPilot -workspace CoPilot.xcworkspace
