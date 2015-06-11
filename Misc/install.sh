#!/bin/sh

DOWNLOAD_URI=https://github.com/feinstruktur/CoPilot/releases/download/0.11/CoPilot.xcplugin-0.11.zip
PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
FNAME=dl.zip

mkdir -p "${PLUGINS_DIR}"
cd "${PLUGINS_DIR}"
curl -L $DOWNLOAD_URI -o $FNAME
unzip $FNAME
rm -rf $FNAME

# the 1 is not a typo!
echo "CoPilot successfully installed!!1!🍻   Please restart your Xcode."
