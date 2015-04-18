//
//  CoPilotPluginTests.swift
//  CoPilotPluginTests
//
//  Created by Sven Schmidt on 18/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble

import CryptoSwift


func diff(a: String?, b: String?, checklines: Bool = true, deadline: NSTimeInterval = 1) -> [Diff] {
    let d = DiffMatchPatch()
    if let diffs = d.diff_mainOfOldString(a, andNewString: b, checkLines: checklines, deadline: deadline) {
        return NSArray(array: diffs) as! [Diff]
    } else {
        return [Diff]()
    }
}


func patch(diffs: [Diff]) -> [Patch] {
    let d = DiffMatchPatch()
    if let patches = d.patch_makeFromDiffs(NSMutableArray(array: diffs)) {
        return NSArray(array: patches) as! [Patch]
    } else {
        return [Patch]()
    }
}


struct Document {
    var text: String
    var hash: String {
        return self.text.md5()!
    }
}


class CoPilotPluginTests: XCTestCase {
    
    func test_diff() {
        let d = diff("foo2bar", "foobar")
        expect(d.count) == 3
        expect(d[0].operation) == Operation.DiffEqual
        expect(d[0].text) == "foo"
        expect(d[1].operation) == Operation.DiffDelete
        expect(d[1].text) == "2"
        expect(d[2].operation) == Operation.DiffEqual
        expect(d[2].text) == "bar"
    }
    
    
    func test_patches() {
        let diffs = diff("foo2bar", "foobar")
        let patches = patch(diffs)
        expect(patches.count) == 1
        let lines = patches[0].description.componentsSeparatedByString("\n")
        expect(lines[0]) == "@@ -1,7 +1,6 @@"
        expect(lines[1]) == " foo"
        expect(lines[2]) == "-2"
        expect(lines[3]) == " bar"
        expect(patches[0].start1) == 0
        expect(patches[0].start2) == 0
        expect(patches[0].length1) == 7
        expect(patches[0].length2) == 6
    }
    
    
    func test_apply() {
        let diffs = diff("foo2bar", "foobar")
        let patches = patch(diffs)
        let dmp = DiffMatchPatch()
        let res = dmp.patch_apply(NSArray(array: patches) as [AnyObject], toString: "foo2bar")
        println(res)
    }
    
    
    func test_hash() {
        let doc = Document(text: "The quick brown fox jumps over the lazy dog")
        expect(doc.hash) == "9e107d9d372bb6826bd81d3542a419d6".uppercaseString
    }
    
}
