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


class WebSocket: NSObject {
    let socket: PSWebSocket
    var onConnect: (Void -> Void)?
    init(url: NSURL, onConnect: (Void -> Void)) {
        self.onConnect = onConnect
        let req = NSURLRequest(URL: url)
        self.socket = PSWebSocket.clientSocketWithRequest(req)
        super.init()
        self.socket.delegate = self
        self.socket.open()
    }
}

extension WebSocket: PSWebSocketDelegate {
    
    func webSocketDidOpen(webSocket: PSWebSocket!) {
        self.onConnect?()
    }
    
    func webSocket(webSocket: PSWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didFailWithError error: NSError!) {
        
    }
}


class DocClientTests: XCTestCase {

    func test_client() {
        let s = startServer()
        let url = NSURL(string: "ws://localhost:\(CoPilotService.port)")!
        var open = false
        let socket = WebSocket(url: url) {
            open = true
        }
        expect(open).toEventually(beTrue(), timeout: 5)
    }
    
}

