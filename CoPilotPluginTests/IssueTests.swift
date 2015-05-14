//
//  IssueTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 14/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


class IssueTests: XCTestCase {

    // https://bitbucket.org/feinstruktur/copilot/issue/7/crash-when-cursor-at-end-and-receiving-an
    func test_issue_7() {
        let tv = NSTextView()
        let a = "123"
        let newDoc = Document("0123")
        tv.string = a
        expect(count(tv.string!)) == 3
        tv.setSelectedRange(NSRange(location: 3, length: 0))
        
        let patches = computePatches(tv.string, newDoc.text)
        let selected = tv.selectedRange
        let currentPos = Position(selected.location)
        let newPos = newPosition(currentPos, patches)
        
        tv.textStorage?.replaceAll(newDoc.text)
        
        let newSelection = adjustSelection(selected, newPos, count(newDoc.text))
        tv.setSelectedRange(newSelection)
    }
    
}
