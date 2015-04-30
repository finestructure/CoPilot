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


func createSocket() -> WebSocket {
    var open = false
    let socket = WebSocket(url: TestUrl) {
        open = true
    }
    expect(open).toEventually(beTrue(), timeout: 5)
    return socket
}


let TestUrl = NSURL(string: "ws://localhost:\(CoPilotService.port)")!


class DocClientTests: XCTestCase {

    func test_server() {
        let server = startServer()
        var open = false
        let socket = WebSocket(url: TestUrl) {
            open = true
        }
        expect(open).toEventually(beTrue(), timeout: 5)
        expect(server.sockets.count) == 1
    }

    func test_broadcast() {
        let server = startServer()
        let socket = createSocket()
        var received: String?
        server.broadcast("hello")
        expect(socket.lastMessage?.string).toEventually(equal("hello"), timeout: 5)
    }
    
    func test_send() {
        let server = startServer()
        let socket = createSocket()
        var received: String?
        socket.send("foo")
        expect(server.sockets.count).toEventually(equal(1), timeout: 5)
        expect(server.sockets[0].lastMessage?.string).toEventually(equal("foo"), timeout: 5)
    }
    
}

