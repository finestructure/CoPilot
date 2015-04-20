//
//  BonjourTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


let CoPilotService = BonjourService(name: "CoPilot", domain: "local", type: "_copilot._tcp", port: 8137)


struct BonjourService {
    let name: String
    let domain: String
    let type: String
    let port: Int32
}


func publish(service: BonjourService) -> NSNetService {
    let s = NSNetService(domain: service.domain, type: service.type, name: service.name, port: service.port)
    s.publish()
    return s
}


class BonjourTests: XCTestCase {

    
    func test_publish() {
        let s = publish(CoPilotService)
        expect(s).toNot(beNil())
    }
    

}
