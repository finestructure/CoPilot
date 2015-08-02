//
//  DocClientServerTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble
import FeinstrukturUtils


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


extension DocNode {

    func setBufferTime(bufferTime: NSTimeInterval) {
        self.docThrottle = Throttle(bufferTime: bufferTime)
        self.selThrottle = Throttle(bufferTime: bufferTime)
    }
    
}


func createClient(document  document: Document) -> DocClient {
    var service: NSNetService?
    let b = Browser(service: CoPilotBonjourService) { s in
        service = s
    }
    expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail
    expect(service).toEventuallyNot(beNil(), timeout: 2)
    return DocClient(service: service!, document: document)
}


class DocClientServerTests: XCTestCase {

    func test_server() {
        let doc = { Document(randomElement(words)!) }
        let server = DocServer(name: "foo", document: doc())
        defer { server.stop() }
        server.setBufferTime(0)
        let t = Timer(interval: 0.1) { server.update(doc()) }
        expect(t).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            messages.append(msg)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }

    
    func test_nsNetService() {
        let doc = { Document(randomElement(words)!) }
        let server = DocServer(name: "foo", document: doc())
        defer { server.stop() }
        let t = Timer(interval: 0.1) { server.update(doc()) }
        expect(t).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        var service: NSNetService!
        let b = Browser(service: CoPilotBonjourService) { s in service = s }
        expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        expect(service).toEventuallyNot(beNil(), timeout: 5)
        
        let client = DocClient(service: service, document: Document(""))
        var changeCount = 0
        client.onDocumentUpdate = { _ in changeCount++ }
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }


    func test_connect_url() {
        let doc = { Document(randomElement(words)!) }
        let server = DocServer(name: "foo", document: doc())
        defer { server.stop() }
        _ = Timer(interval: 0.1) { server.update(doc()) }
        let url = NSURL(string: "ws://localhost:\(CoPilotBonjourService.port)")!

        let client = DocClient(url: url, document: Document(""))
        var changeCount = 0
        client.onDocumentUpdate = { _ in changeCount++ }
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }

    
    func test_sendChanges() {
        let server = DocServer(name: "foo", document: Document("foo"))
        defer { server.stop() }
        let client1 = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let client2 = createClient(document: client2Doc)
        server.update(Document("foobar"))
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }
    
    
    func test_conflict_server_update() {
        let doc = { Document("initial") }
        let server = DocServer(name: "", document: doc())
        defer { server.stop() }
        let client = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client.document.text).toEventually(equal("initial"), timeout: 5)
        
        // simulate a conflict by changing both server and client docs
        // we do this by changing the underlying client ivar without triggering the .Update messages
        client._document = Document("client")
        
        // and then send an update from the server
        server.update(Document("server"))
        
        expect(server.document.text).toEventually(equal("server"))
        expect(client.document.text).toEventually(equal("server"))
    }
    
    
    func test_conflict_client_update() {
        let doc = { Document("initial") }
        let server = DocServer(name: "", document: doc())
        defer { server.stop() }
        let client = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client.document.text).toEventually(equal("initial"), timeout: 5)

        // simulate a conflict by changing both server and client docs
        // we do this by changing the underlying client ivar without triggering the .Update messages
        server._document = Document("server")

        // and then send an update from the client
        client.update(Document("client"))

        expect(server.document.text).toEventually(equal("server"))
        expect(client.document.text).toEventually(equal("server"))
    }


    func test_sync_back() {
        let serverDoc = Document("foo")
        let server = DocServer(name: "server", document: serverDoc)
        defer { server.stop() }

        let client1 = createClient(document: Document(""))
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2 = createClient(document: Document(""))
        expect(client2.document.text).toEventually(equal("foo"), timeout: 5)

        server.update(Document("foobar"))
        
        expect(server.document.text).toEventually(equal("foobar"), timeout: 5)
        expect(client1.document.text).toEventually(equal("foobar"), timeout: 5)
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)

        client1.update(Document("bar"))
        
        expect(server.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client1.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client2.document.text).toEventually(equal("bar"), timeout: 1)
    }
    
}

