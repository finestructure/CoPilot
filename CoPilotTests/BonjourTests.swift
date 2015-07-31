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


class BonjourTests: XCTestCase {

    var resolved = false
    
    func test_publish() {
        let service = CoPilotBonjourService.publish(name: "Test")
        expect(service).toNot(beNil())
        
        var found: NSNetService?
        let b = Browser(service: CoPilotBonjourService) { service in
            found = service
        }
        expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail

        expect(found).toEventuallyNot(beNil(), timeout: 5)
        expect(found?.type) == "_copilot._tcp."
    }

    
    func test_Browser_add_remove() {
        var services = [NSNetService]()
        services.append( CoPilotBonjourService.publish(name: "Test1") )
        
        var found = false
        let b = Browser(service: CoPilotBonjourService) { service in
            if service.name.hasPrefix("Test") {
                found = true
            }
        }
        expect(found).toEventually(beTrue(), timeout: 5)
        let initial = b.count
        expect(initial) > 0

        found = false
        services.append( CoPilotBonjourService.publish(name: "Test2") )
        expect(found).toEventually(beTrue(), timeout: 5)
        expect(b.count) == initial + 1
        
        var removed = false
        b.onRemove = { service in
            removed = true
        }
        services.removeAtIndex(0)
        expect(removed).toEventually(beTrue(), timeout: 5)
        expect(b.count) == initial
    }
    
    
    func test_resolve() {
        let publishedService = CoPilotBonjourService.publish(name: "Test")
        expect(publishedService).toNot(beNil()) // just to silence the warning, using _ will make the test fail

        var service: NSNetService?
        let b = Browser(service: CoPilotBonjourService) { svc in service = svc }
        expect(b).toNot(beNil()) // just to silence the warning, using _ will make the test fail
        expect(service).toEventuallyNot(beNil(), timeout: 5)

        let resolver = Resolver(service: service!, timeout: 1) { _ in }
        expect(resolver.resolved).toEventually(beTrue())
    }

}

