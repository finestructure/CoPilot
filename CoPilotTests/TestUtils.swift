//
//  TestUtils.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 24/07/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import Nimble


let TestUrl = NSURL(string: "ws://localhost:\(CoPilotService.port)")!


func startServer() -> Server {
    let s = Server(name: "foo", service: CoPilotService)
    var started = false
    s.onPublished = { ns in
        expect(ns).toNot(beNil())
        started = true
    }
    s.start()
    expect(started).toEventually(beTrue(), timeout: 10)
    return s
}


func createClient(url: NSURL = TestUrl) -> WebSocket {
    return connectWebsocket(url)
}


func connectWebsocket(url: NSURL) -> WebSocket {
    var open = false
    let socket = WebSocket(url: url) {
        open = true
    }
    expect(open).toEventually(beTrue(), timeout: 5)
    return socket
}
