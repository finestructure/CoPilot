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

    override func tearDown() {
        ConnectionManager.disconnectAll()
    }
    
    
    func test_connected_published_subscribed() {
        let pub = createEditor()
        let sub = createEditor()
        
        expect(ConnectionManager.isPublished(pub)) == false
        expect(ConnectionManager.isPublished(sub)) == false
        expect(ConnectionManager.isSubscribed(pub)) == false
        expect(ConnectionManager.isSubscribed(sub)) == false
        expect(ConnectionManager.isConnected(pub)) == false
        expect(ConnectionManager.isConnected(sub)) == false

        ConnectionManager.publish(pub)
        let service = publish(service: CoPilotService, name: "Test")
        ConnectionManager.subscribe(service, editor: sub)
        
        expect(ConnectionManager.isPublished(pub)) == true
        expect(ConnectionManager.isPublished(sub)) == false
        expect(ConnectionManager.isSubscribed(pub)) == false
        expect(ConnectionManager.isSubscribed(sub)) == true
        expect(ConnectionManager.isConnected(pub)) == true
        expect(ConnectionManager.isConnected(sub)) == true
    }
    
    
    func test_filters() {
        let pub = createEditor()
        let sub = createEditor()
        ConnectionManager.publish(pub)
        let service = publish(service: CoPilotService, name: "Test")
        ConnectionManager.subscribe(service, editor: sub)

        expect(ConnectionManager.published({ $0.editor == sub })).to(beNil())
        expect(ConnectionManager.published({ $0.editor == pub })?.editor) == pub
        expect(ConnectionManager.subscribed({ $0.editor == sub })?.editor) == sub
        expect(ConnectionManager.subscribed({ $0.editor == pub })).to(beNil())
        expect(ConnectionManager.connected({ $0.editor == sub })?.editor) == sub
        expect(ConnectionManager.connected({ $0.editor == pub })?.editor) == pub
    }
    
}


func createEditor() -> Editor {
    let editor = NSViewController()
    let win = NSWindow()
    return Editor(editor: editor, window: win)
}
