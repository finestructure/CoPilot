# CoPilot

CoPilot is an Xcode plugin that allows collaborative editing over the network.

[CoPilot Homepage](http://feinstruktur.com/copilot)

![Image of CoPilot](https://raw.githubusercontent.com/feinstruktur/CoPilot/master/Misc/screenshot-readme.png)

## Compatibility

CoPilot has been tested on Xcode 6.3.2. It should run on 6.4 and other versions of Xcode.

## Availability

CoPilot can now be installed via by running the following command in the terminal:
```
curl -fsSL https://raw.githubusercontent.com/feinstruktur/CoPilot/master/Misc/install.sh | sh
```
Astute readers will recognise this a striking similariry to Alcatraz' way of installing :) Alcatraz integration will hopefull follow soon, pending the merge of [this pull request](https://github.com/supermarin/Alcatraz/pull/295).

## Build Instructions

- `git clone git@github.com:feinstruktur/CoPilot.git`
- `cd CoPilot`
- `git submodule update --init --recursive`
- `pod install`
