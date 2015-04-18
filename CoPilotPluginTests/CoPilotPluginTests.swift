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


let dmp = DiffMatchPatch()


func diff(a: String!, b: String!, checklines: Bool = true, deadline: NSTimeInterval = 1) -> [Diff] {
    let d = DiffMatchPatch()
    let diffs = d.diff_mainOfOldString(a, andNewString: b, checkLines: checklines, deadline: deadline)
    return NSArray(array: diffs) as! [Diff]
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
    
    
    func test_md5() {
        let hash = "The quick brown fox jumps over the lazy dog".md5()
        expect(hash) == "9e107d9d372bb6826bd81d3542a419d6".uppercaseString
    }
    
}
