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

    var server: DocServer!


    override func tearDown() {
        self.server?.stop()
    }


    // Crash when cursor at end and receiving an insertion
    // https://github.com/feinstruktur/CoPilot/issues/7
    func test_issue_7() {
        let tv = NSTextView()
        let a = "123"
        let newDoc = Document("0123")
        tv.string = a
        expect(tv.string!.characters.count) == 3
        tv.setSelectedRange(NSRange(location: 3, length: 0))
        
        let patches = computePatches(tv.string, b: newDoc.text)
        let selected = tv.selectedRange
        let currentPos = Position(selected.location)
        let newPos = newPosition(currentPos, patches: patches)
        
        tv.textStorage?.replaceAll(newDoc.text)
        
        let newSelection = adjustSelection(selected, newPosition: newPos, newString: newDoc.text)
        tv.setSelectedRange(newSelection)
    }
    
    
    // Insertion point not preserved when emojis appear
    // https://github.com/feinstruktur/CoPilot/issues/8
    func test_issue_8() {
        // NSString based subsystems count 🔥 as 2 characters
        // we need to use (s as NSString).length instead of count(s) to stay in NSString's 'coordinate system'
        let s = "🔥" as NSString
        expect(s.length) == 2
        expect("🔥".characters.count) == 1

        let patches = computePatches("123", b: "🔥123")
        expect(newPosition(3, patches: patches)) == 5 // diff subsytems and NSTextView selections 'see' 🔥 as 2 characters
    }


    // Client changes get nuked by server, always
    // https://github.com/feinstruktur/CoPilot/issues/14
    func test_issue_14() {
        let serverDoc = Document("foo")
        self.server = DocServer(name: "server", document: serverDoc)

        let client1 = createClient(document: Document(""))
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2 = createClient(document: Document(""))
        expect(client2.document.text).toEventually(equal("foo"), timeout: 5)

        // make quick client changes that fall inside the buffer - this triggers the bug of the _document getting updated and causing the doc to go out of sync with the actual Changeset (baseRef) that's being sent
        client1.update(Document("b"))
        client1.update(Document("ba"))
        client1.update(Document("bar"))

        expect(self.server.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client1.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client2.document.text).toEventually(equal("bar"), timeout: 1)

        // now test the reverse direction making quick changes server side
        self.server.update(Document("f"))
        self.server.update(Document("fo"))
        self.server.update(Document("foo"))

        // the server side quick updates always worked but only because the clients would request a resync when there's a conflict
        expect(self.server.document.text).toEventually(equal("foo"), timeout: 1)
        expect(client1.document.text).toEventually(equal("foo"), timeout: 1)
        expect(client2.document.text).toEventually(equal("foo"), timeout: 1)
    }

    
    // Crashes on subscribe (Xcode7/OSX 10.11)
    // https://github.com/feinstruktur/CoPilot/issues/36
    func test_issue_36() {
        let server_txt = contentsOfFile(name: "issue_36_server", type: "txt")
        let client_txt = contentsOfFile(name: "issue_36_client", type: "txt")
        let patches = computePatches(client_txt, b: server_txt)
        expect(server_txt.characters.count) == 276
        expect(client_txt.characters.count) == 86

        for idx: Position in 0..<86 {
            switch idx {
            case 0..<15:
                expect(newPosition(idx, patches: patches)) == idx
            case 15..<54:
                expect(newPosition(idx, patches: patches)) == 244
            case 54..<86:
                expect(newPosition(idx, patches: patches)) == 244 + (idx - 54)
            default:
                fail("unhandled index range")
            }
        }
    }
    
}
