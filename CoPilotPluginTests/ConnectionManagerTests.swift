//
//  ConnectionManagerTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


class ConnectionManagerTests: XCTestCase {

    func test_publish_isPublished() {
        let win = NSWindow()
        let doc = NSDocument()
        let ts = NSTextStorage()
        let ed = Editor(window: win, document: doc, textStorage: ts)

        expect(ConnectionManager.isPublished(ed)) == false
        ConnectionManager.publish(ed)
        expect(ConnectionManager.isPublished(ed)) == true
    }

}
