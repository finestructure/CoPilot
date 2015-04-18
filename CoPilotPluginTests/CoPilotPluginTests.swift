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
    
}
