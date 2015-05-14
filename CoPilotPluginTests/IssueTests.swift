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
        
        let newSelection = adjustSelection(selected, newPos, newDoc.text)
        tv.setSelectedRange(newSelection)
    }
    
    
    // https://bitbucket.org/feinstruktur/copilot/issue/8/insertion-point-not-preserved-when-emojis
    func test_issue_8() {
        // NSString based subsystems count 🔥 as 2 characters
        // we need to use (s as NSString).length instead of count(s) to stay in NSString's 'coordinate system'
        let s = "🔥" as NSString
        expect(s.length) == 2
        expect(count("🔥")) == 1

        var patches = computePatches("123", "🔥123")
        expect(newPosition(3, patches)) == 5 // diff subsytems and NSTextView selections 'see' 🔥 as 2 characters
    }
    
}
