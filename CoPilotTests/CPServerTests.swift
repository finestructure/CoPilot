//
//  CPIceTests.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 24/07/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble
import HastyHare
import Async


func docUrl(docId: String) -> NSURL {
    return NSURL(string: "ws://localhost:12345/doc/\(docId)")!
}


extension Socket {
    func send(string: String) {
        self.send(Message(string))
    }
}


extension Message {
    init(encodeAsData: String) { self = Message.Data(encodeAsData.dataUsingEncoding(NSUTF8StringEncoding)!) }
}


func connectDoc(connectionId: ConnectionId) -> Socket {
    let s = RabbitSocket(connectionId: connectionId)
    s.open()
    return s
}


class RabbitServerTests: XCTestCase {

    func test_cpserver() {
        do { // document host
            let s = connectDoc("doc1")
            s.send(Command(name: "server"))
        }
        do { // document client
            var s = connectDoc("doc1")

            var msg: Message?
            s.onReceive = { m in
                msg = m
            }
            expect(msg?.data).toEventuallyNot(beNil(), timeout: 2)
            if let d = msg?.data {
                let cmd = Command(data: d)
                expect(cmd.name) == Optional("server")
            } else {
                fail("could not decode message")
            }
        }
    }


    func test_publish() {
        fail("implement publish test")
    }


    func test_unpublish() {
        fail("implement unpublish test")
    }

    
    func test_broadcast() {
        fail("implement broadcast test")
    }

    
    func test_send() {
        fail("implement send test")
    }

    
    func test_sendChanges() {
        let server = RabbitDocServer(name: "doc1", document: Document("foo"))
        defer { server.stop() }

        let client1 = DocClient(connectionId: server.id, document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let client2 = createClient(document: client2Doc)
        server.update(Document("foobar"))
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }


    // TODO: implement remaining tests from DocClientServerTests (i.e. implement RabbitMQ variant of those BonjourServer based tests

}
