//
//  CPIceTests.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 24/07/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble


let GoPublishUrl = NSURL(string: "ws://localhost:12345/doc/1/publish")!
let GoSubscribeUrl = NSURL(string: "ws://localhost:12345/doc/1/subscribe")!


class CPIceTests: XCTestCase {

    func test_goserver() {
        let s = connectWebsocket(GoPublishUrl)
        expect(s).toNot(beNil())
        let c = connectWebsocket(GoSubscribeUrl)
        expect(c).toNot(beNil())
        var message: Message?
        c.onReceive = { msg in
            message = msg
        }
        c.onDisconnect = { error in
            fail("error: \(error)")
        }
        s.onDisconnect = { error in
            fail("error: \(error)")
        }
        s.send(Command(name: "server"))
        expect(message).toEventuallyNot(beNil())
        print("message: \(message)")
    }

}
