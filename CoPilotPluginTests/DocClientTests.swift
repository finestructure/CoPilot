//
//  DocClientTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 30/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


typealias ChangeHandler = (Void -> Void)

class DocClient {
    private let service: NSNetService
    private let onChange: ChangeHandler
    init(service: NSNetService, onChange: ChangeHandler) {
        self.service = service
        self.onChange = onChange
    }
}


func startServer() -> Server {
    let s = Server(name: "foo", service: CoPilotService)
    var started = false
    s.onPublished = { ns in
        expect(ns).toNot(beNil())
        started = true
    }
    s.start()
    expect(started).toEventually(beTrue(), timeout: 5)
    return s
}


class DocClientTests: XCTestCase {
    var open = false

    func test_client() {
        let s = startServer()
        let url = NSURL(string: "ws://localhost:\(CoPilotService.port)")!
        let req = NSURLRequest(URL: url)
        self.open = false
        let socket = PSWebSocket.clientSocketWithRequest(req)
        socket.delegate = self
        socket.open()
        expect(self.open).toEventually(beTrue(), timeout: 5)
    }
    
}


extension DocClientTests: PSWebSocketDelegate {
    
    func webSocketDidOpen(webSocket: PSWebSocket!) {
        self.open = true
    }
    
    func webSocket(webSocket: PSWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didFailWithError error: NSError!) {
        
    }
    
}