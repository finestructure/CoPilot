[![Twitter: @_sa_s](https://img.shields.io/badge/contact-%40__sa__s-blue.svg)](https://twitter.com/_sa_s) [![](http://img.shields.io/badge/Swift-2.0-blue.svg)]()

# CoPilot

CoPilot is an Xcode plugin that allows collaborative editing over the network.

[![CoPilot Video](https://raw.githubusercontent.com/feinstruktur/CoPilot/master/Misc/screenshot-readme.png)](http://feinstruktur.com/copilot)

## Home Page

Please see the [CoPilot Homepage](http://feinstruktur.com/copilot) for further details.

## Compatibility

CoPilot has been tested on Xcode 6.3.2, 6.4, and 7.x. It should also run on other versions of Xcode but you may have to add its UUID to Info.plist.

## Installing

CoPilot can be installed via by running the following command in the terminal:
```
curl -fsSL https://raw.githubusercontent.com/feinstruktur/CoPilot/master/Misc/install.sh | sh
```
Astute readers will recognise a striking similariry to Alcatraz' way of installing :) Until Alcatraz allows for binary installs this is the easiest way to get up and running. Yes, it's not great to pipe a URL into `sh` so please review [`install.sh`](https://raw.githubusercontent.com/feinstruktur/CoPilot/master/Misc/install.sh) or download and run it manually.

## Build Instructions

- `git clone git@github.com:feinstruktur/CoPilot.git`
- `cd CoPilot`
- `git submodule update --init --recursive`

