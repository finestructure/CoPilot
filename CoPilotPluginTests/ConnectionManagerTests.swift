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

    func test_isPublished() {
        let ctr = NSViewController()
        let doc = NSDocument()
        let ts = NSTextStorage()
        let ed = Editor(controller: ctr, document: doc, textStorage: ts)
        let pub = publishEditor(ed)
        
        expect(ConnectionManager.isPublished(ed)) == false
        ConnectionManager.published.append(pub)
        expect(ConnectionManager.isPublished(ed)) == true
    }

}
