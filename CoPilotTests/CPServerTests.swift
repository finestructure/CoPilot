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


    //    func test_sendChanges() {
    //        let svc: DocumentService = CPServer(document: Document("foo"))
    //        svc.publish("d1")
    //        defer { svc.unpublish() }
    //
    //        let client1 = createClient(document: Document(""))
    //        // wait for the initial .Doc to set up the client
    //        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)
    //
    //        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
    //        let client2 = createClient(document: client2Doc)
    //        server.update(Document("foobar"))
    //        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    //    }


    func test_sendChanges() {
        let s = RabbitDocServer(name: "doc1", document: Document("foo"))
        defer { s.stop() }

        let client1 = DocClient(connectionId: s.id, document: Document(""))
        // wait for the initial .Doc to set up the client
        expect(client1.document.text).toEventually(equal("foo"), timeout: 5)
//
//        let client2Doc = Document(contentsOfFile(name: "new_playground", type: "txt"))
//        let client2 = createClient(document: client2Doc)
//        server.update(Document("foobar"))
//        expect(client2.document.text).toEventually(equal("foobar"), timeout: 5)
    }


    func _test_birectional() {
        let s = connectWebsocket(docUrl("1"))
        expect(s).toNot(beNil())
        let c = connectWebsocket(docUrl("1"))
        expect(c).toNot(beNil())
        var message: Message?
        c.onReceive = { msg in
            message = msg
        }
        var response: Message?
        s.onReceive = { msg in
            response = msg
        }
        c.onDisconnect = { error in
            fail("error: \(error)")
        }
        s.onDisconnect = { error in
            fail("error: \(error)")
        }

        if s.isOpen {
            s.send(Command(name: "ping"))
            expect(message).toEventuallyNot(beNil())
            if let data = message?.data {
                expect(Command(data: data).name) == "ping"
            }

            c.send(Command(name: "pong"))
            expect(response).toEventuallyNot(beNil())
            expect(Command(data: response!.data!).name) == "pong"
        } else {
            fail("socket not open - is cpserver running?")
        }
    }


    func _test_two_subscribers() {
        let s = connectWebsocket(docUrl("2"))
        let c1 = connectWebsocket(docUrl("2"))
        let c2 = connectWebsocket(docUrl("2"))

        var sMsg = [Message]()
        s.onReceive = { msg in
            sMsg.append(msg)
        }

        var c1Msg = [Message]()
        c1.onReceive = { msg in
            c1Msg.append(msg)
        }

        var c2Msg = [Message]()
        c2.onReceive = { msg in
            c2Msg.append(msg)
        }

        if s.isOpen {
            s.send(Command(name: "server"))

            expect(c1Msg.count).toEventually(equal(1))
            expect(Command(data: c1Msg[0].data!).name) == "server"
            expect(c2Msg.count).toEventually(equal(1))
            if let data = c2Msg.first?.data {
                expect(Command(data: data).name) == "server"
            }
            expect(sMsg.count) == 0

            c1.send(Command(name: "c1"))

            expect(c1Msg.count) == 1
            expect(c2Msg.count).toEventually(equal(2))
            expect(sMsg.count).toEventually(equal(1))
        } else {
            fail("socket not open - is cpserver running?")
        }
    }


    func _test_no_echo() {
        let s = connectWebsocket(docUrl("3"))
        expect(s).toNot(beNil())
        var messages = [Message]()
        s.onReceive = { msg in
            messages.append(msg)
        }

        if s.isOpen {
            s.send(Command(name: "1"))

            let c = connectWebsocket(docUrl("3"))
            c.send(Command(name: "2"))

            // make sure the first command does not get echoed back to "s", only the second one should appear
            expect(messages.count).toEventually(beGreaterThan(0))
            expect(Command(data: messages[0].data!).name) == "2"
        } else {
            fail("socket not open - is cpserver running?")
        }
    }


    func _test_document_separation() {
        let a1 = connectWebsocket(docUrl("a"))
        let a2 = connectWebsocket(docUrl("a"))
        let b1 = connectWebsocket(docUrl("b"))
        let b2 = connectWebsocket(docUrl("b"))

        var a1Msg = [Message]()
        a1.onReceive = { m in a1Msg.append(m) }
        var a2Msg = [Message]()
        a2.onReceive = { m in a2Msg.append(m) }
        var b1Msg = [Message]()
        b1.onReceive = { m in b1Msg.append(m) }
        var b2Msg = [Message]()
        b2.onReceive = { m in b2Msg.append(m) }

        if a1.isOpen {
            a1.send("a")
            b1.send("b")

            expect(a2Msg.count).toEventually(equal(1))
            expect(a2Msg[0]) == Message(encodeAsData: "a")
            expect(a1Msg.count) == 0

            expect(b2Msg.count).toEventually(equal(1))
            expect(b2Msg.first) == Message(encodeAsData: "b")
            expect(b1Msg.count) == 0
        } else {
            fail("socket not open - is cpserver running?")
        }
    }

}
