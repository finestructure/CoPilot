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

        var msg: Message?

        do { // document client
            let s = RabbitSocket(docId: "doc1")
            s.open()
            s.onReceive = { m in
                msg = m
            }
        }

        do { // document host
            let s = RabbitSocket(docId: "doc1")
            s.open()
            s.send(Command(name: "server"))
        }

        expect(msg?.data).toEventuallyNot(beNil(), timeout: 2)
        if let d = msg?.data {
            let cmd = Command(data: d)
            expect(cmd.name) == Optional("server")
        } else {
            fail("could not decode message")
        }

    }


    func test_socket_3way() {
        var messages = [
            "1": [Command](),
            "2": [Command](),
            "server": [Command](),
        ]

        // server
        let server: RabbitSocket = {
            let s = RabbitSocket(docId: "doc1")
            s.open()
            s.onReceive = { m in
                let cmd = Command(data: m.data!)
                messages["server"]?.append(cmd)
            }
            return s
        }()
        server.send(Command(name: "server"))

        // client 1
        let c1: RabbitSocket = {
            let s = RabbitSocket(docId: "doc1")
            s.open()
            s.onReceive = { m in
                messages["1"]?.append(Command(data: m.data!))
            }
            return s
        }()
        c1.send(Command(name: "c1"))

        // client 2
        let c2: RabbitSocket = {
            let s = RabbitSocket(docId: "doc1")
            s.open()
            s.onReceive = { m in
                messages["2"]?.append(Command(data: m.data!))
            }
            return s
        }()
        c2.send(Command(name: "c2"))

        let block = Async.background {  // Need to validate on a background queue to avoid deadlock/timeout. Without this, the first test will timeout (fail) and the remining will pass.
            expect(messages["server"]?.description).toEventually(equal("[.Name server, .Name c1, .Name c2]"))
            expect(messages["1"]?.description).toEventually(equal("[.Name c1, .Name c2]"))
            expect(messages["2"]?.description).toEventually(equal("[.Name c2]"))
        }
        block.wait()

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
    func test_sendChanges() {
        let server = DocServer(name: "doc name", document: Document("foo"), serverType: .RabbitServer)
        defer { server.stop() }

        let client1 = DocClient(name: "client1", connectionId: server.id, document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)

        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let client2 = DocClient(name: "client2", connectionId: server.id, document: client2Doc)
        server.update(Document("foobar"))
        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }


    // TODO: implement remaining tests from DocClientServerTests (i.e. implement RabbitMQ variant of those BonjourServer based tests

}
