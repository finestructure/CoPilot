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


let TestUrl = NSURL(string: "ws://localhost:\(CoPilotService.port)")!


//typealias ChangeHandler = (Void -> Void)
//
//class DocClient {
//    private let service: NSNetService
//    private let onChange: ChangeHandler
//    init(service: NSNetService, onChange: ChangeHandler) {
//        self.service = service
//        self.onChange = onChange
//    }
//}



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
        let client = createClient()
        var received: String?
        server.broadcast("hello")
        expect(client.lastMessage?.string).toEventually(equal("hello"), timeout: 5)
    }
    
    
    func test_send() {
        let server = startServer()
        let client = createClient()
        var received: String?
        client.send("foo")
        expect(server.sockets.count).toEventually(equal(1), timeout: 5)
        expect(server.sockets[0].lastMessage?.string).toEventually(equal("foo"), timeout: 5)
    }
    
    
    func test_sendChanges() {
        let initialServerDoc = Document("Some Document")
        let finalServerDoc = Document("Server Document")
        let clientDoc = Document("Some Document")
        let changeSet = Changeset(source: initialServerDoc, target: finalServerDoc)
        
        let server = startServer()
        let client = createClient()
        
        server.broadcast(changeSet.data)
        expect(client.lastMessage?.data).toEventuallyNot(beNil(), timeout: 5)
        let d = client.lastMessage!.data!
        
        let decoder = NSKeyedUnarchiver(forReadingWithData: d)
        let patches = decoder.decodeObjectForKey("patches") as! NSArray
        expect(patches).toNot(beNil())
        println(patches)
    }
    
}


// MARK: - Helpers


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


func createClient() -> WebSocket {
    var open = false
    let socket = WebSocket(url: TestUrl) {
        open = true
    }
    expect(open).toEventually(beTrue(), timeout: 5)
    return socket
}
