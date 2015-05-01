//
//  DocServerTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble
import FeinstrukturUtils


typealias TextProvider = (Void -> String)

class DocServer: NSObject {
    
    private let textProvider: TextProvider
    private let server: Server
    private var timer: NSTimer?
    
    init(name: String, service: BonjourService = CoPilotService, textProvider: TextProvider) {
        self.textProvider = textProvider
        self.server = Server(name: name, service: service)
        self.server.start()
        self.timer = nil
        super.init()
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pollProvider", userInfo: nil, repeats: true)
        self.timer = timer
    }

    func pollProvider() {
        let s = self.textProvider()
        self.server.broadcast(s)
    }
    
}


let words = [
    "this",
    "is",
    "some",
    "list",
    "of",
    "totally",
    "arbitrary",
    "words",
]

class DocServerTests: XCTestCase {

    func test_server() {
        let s = DocServer(name: "foo", textProvider: {
            return randomElement(words)!
        })
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            messages.append(msg)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }
    
}
