#!/bin/sh

VERSION=0.12
DOWNLOAD_URI=https://github.com/feinstruktur/CoPilot/releases/download/${VERSION}/CoPilot.xcplugin-${VERSION}.zip
PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
FNAME=dl.zip

mkdir -p "${PLUGINS_DIR}"
cd "${PLUGINS_DIR}"
curl -L $DOWNLOAD_URI -o $FNAME
unzip -o $FNAME
rm -rf $FNAME

# the 1 is not a typo!
echo "CoPilot ${VERSION} successfully installed!!1!🍻   Please restart your Xcode."
