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
    let b = Browser(service: CoPilotService) { s in
        service = s
    }
    expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail
    expect(service).toEventuallyNot(beNil(), timeout: 2)
    return DocClient(service: service!, document: document)
}


class DocClientServerTests: XCTestCase {

    var server: DocServer!
    
    override func tearDown() {
        self.server?.stop()
    }
    
    
    func test_server() {
        let doc = { Document(randomElement(words)!) }
        self.server = DocServer(name: "foo", document: doc())
        self.server.setBufferTime(0)
        let t = Timer(interval: 0.1) { self.server.update(doc()) }
        expect(t).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            messages.append(msg)
            _ = Command(data: msg.data!)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }

    
    func test_DocClient_nsNetService() {
        let doc = { Document(randomElement(words)!) }
        self.server = DocServer(name: "foo", document: doc())
        let t = Timer(interval: 0.1) { self.server.update(doc()) }
        expect(t).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        var service: NSNetService!
        let b = Browser(service: CoPilotService) { s in service = s }
        expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        expect(service).toEventuallyNot(beNil(), timeout: 5)
        
        let client = DocClient(service: service, document: Document(""))
        var changeCount = 0
        client.onDocumentUpdate = { _ in changeCount++ }
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }


    func test_DocClient_url() {
        let doc = { Document(randomElement(words)!) }
        self.server = DocServer(name: "foo", document: doc())
        _ = Timer(interval: 0.1) { self.server.update(doc()) }
        let url = NSURL(string: "ws://localhost:\(CoPilotService.port)")!

        let client = DocClient(url: url, document: Document(""))
        var changeCount = 0
        client.onDocumentUpdate = { _ in changeCount++ }
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }

    
    func test_DocClient_applyChanges() {
        self.server = DocServer(name: "foo", document: Document("foo"))
        let client1 = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let client2 = createClient(document: client2Doc)
        self.server.update(Document("foobar"))
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }
    
    
    func test_conflict_server_update() {
        let serverDoc = Document("initial")
        let doc = { serverDoc }
        self.server = DocServer(name: "", document: doc())
        let client = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client.document.text).toEventually(equal("initial"), timeout: 5)
        
        // simulate a conflict by changing both server and client docs
        // we do this by changing the underlying client ivar without triggering the .Update messages
        client._document = Document("client")
        
        // and then send an update from the server
        self.server.update(Document("server"))
        
        expect(self.server.document.text).toEventually(equal("server"))
        expect(client.document.text).toEventually(equal("server"))
    }
    
    
    func test_conflict_client_update() {
        let serverDoc = Document("initial")
        let doc = { serverDoc }
        self.server = DocServer(name: "", document: doc())
        let client = createClient(document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client.document.text).toEventually(equal("initial"), timeout: 5)

        // simulate a conflict by changing both server and client docs
        // we do this by changing the underlying client ivar without triggering the .Update messages
        self.server._document = Document("server")

        // and then send an update from the client
        client.update(Document("client"))

        expect(self.server.document.text).toEventually(equal("server"))
        expect(client.document.text).toEventually(equal("server"))
    }


    func test_sync_back() {
        let serverDoc = Document("foo")
        self.server = DocServer(name: "server", document: serverDoc)

        let client1 = createClient(document: Document(""))
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2 = createClient(document: Document(""))
        expect(client2.document.text).toEventually(equal("foo"), timeout: 5)

        self.server.update(Document("foobar"))
        
        expect(self.server.document.text).toEventually(equal("foobar"), timeout: 5)
        expect(client1.document.text).toEventually(equal("foobar"), timeout: 5)
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)

        client1.update(Document("bar"))
        
        expect(self.server.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client1.document.text).toEventually(equal("bar"), timeout: 1)
        expect(client2.document.text).toEventually(equal("bar"), timeout: 1)
    }
    
}

