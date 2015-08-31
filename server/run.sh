#!/bin/sh
source gopath
go install cpdocserver && ./bin/cpdocserver
