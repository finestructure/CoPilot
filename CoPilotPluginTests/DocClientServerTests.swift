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


class DocClientServerTests: XCTestCase {

    var server: DocServer!
    
    override func tearDown() {
        self.server.stop()
    }
    
    
    func test_server() {
        let doc = { Document(randomElement(words)!) }
        self.server = DocServer(name: "foo", document: doc())
        self.server.poll(interval: 0.1, docProvider: doc)
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            messages.append(msg)
            let cmd = Command(data: msg.data!)
            println(cmd)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }
    
    
    func _test_sync_files() {
        // manual test, open test files (path is print below) in editor and type to sync changes. Type 'quit' in master doc to quit test.
        let doc = documentProvider("/tmp/server.txt")
        self.server = DocServer(name: "foo", document: doc())
        self.server.poll(interval: 0.1, docProvider: doc)
        let client = DocClient(websocket: WebSocket(url: TestUrl), document: Document(""))
        client.onUpdate = { doc in
            println("client doc: \(doc.text)")
            if try({ e in
                doc.text.writeToFile("/tmp/client.txt", atomically: true, encoding: NSUTF8StringEncoding, error: e)
            }).failed {
                println("writing file failed")
            }
        }
        expect(client.document.text).toEventually(equal("quit"), timeout: 600)
    }
    
    
    func test_DocClient_nsNetService() {
        let doc = { Document(randomElement(words)!) }
        self.server = DocServer(name: "foo", document: doc())
        self.server.poll(interval: 0.1, docProvider: doc)
        var service: NSNetService!
        let browser = Browser(service: CoPilotService) { s in service = s }
        expect(service).toEventuallyNot(beNil(), timeout: 5)
        
        let client = DocClient(service: service, document: Document(""))
        var changeCount = 0
        client.onUpdate = { _ in changeCount++ }
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }
    
    
    func test_DocClient_applyChanges() {
        var serverDoc = Document("foo")
        let doc = { serverDoc }
        self.server = DocServer(name: "foo", document: doc())
        self.server.poll(interval: 0.1, docProvider: doc)
        // we're doing this to not send an intialize to the client2 subscriber
        let client1 = DocClient(websocket: WebSocket(url: TestUrl), document: Document(""))
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let client2 = DocClient(websocket: WebSocket(url: TestUrl), document: client2Doc)
        serverDoc = Document("foobar")
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }
    
    
    func test_sync_back() {
        var serverDoc = Document("foo")
        self.server = DocServer(name: "server", document: serverDoc)

        let client1 = DocClient(websocket: WebSocket(url: TestUrl), document: Document(""))
        client1.clientId = "C1"
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2 = DocClient(websocket: WebSocket(url: TestUrl), document: Document(""))
        client2.clientId = "C2"
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

