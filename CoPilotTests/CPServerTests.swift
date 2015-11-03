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


class RabbitServerTests: XCTestCase {

    func test_socket() {
        do { // document host
            let s = RabbitSocket(connectionId: "doc1")
            s.open()
            s.send(Command(name: "server"))
        }
        do { // document client
            let s = RabbitSocket(connectionId: "doc1")
            s.open()

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


    // FIXME: enable
    func _test_publish() {
        fail("implement publish test")
    }


    // FIXME: enable
    func _test_unpublish() {
        fail("implement unpublish test")
    }

    
    // FIXME: enable
    func _test_broadcast() {
        fail("implement broadcast test")
    }

    
    // FIXME: enable
    func _test_send() {
        fail("implement send test")
    }

    
    // FIXME: enable
    func _test_sendChanges() {
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
