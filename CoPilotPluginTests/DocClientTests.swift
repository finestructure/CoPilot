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


typealias ChangeHandler = (Void -> Void)

class DocClient {
    private let service: NSNetService
    private let onChange: ChangeHandler
    init(service: NSNetService, onChange: ChangeHandler) {
        self.service = service
        self.onChange = onChange
    }
}


class DocClientTests: XCTestCase {

    func test_server() {
        let s = Server(name: "foo", service: CoPilotService)
        var started = false
        s.onPublished = { ns in
            expect(ns).toNot(beNil())
            started = true
        }
        s.start()
        expect(started).toEventually(beTrue(), timeout: 5)
    }
    
}
