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
        let service = publish(service: CoPilotService, name: "Test")
        expect(service).toNot(beNil())
        
        var found: NSNetService!
        let b = Browser(service: CoPilotService) { service in
            found = service
        }

        expect(found).toEventuallyNot(beNil(), timeout: 5)
        expect(found.type) == "_copilot._tcp."
    }

    
    func test_Browser_add_remove() {
        var services = [NSNetService]()
        services.append( publish(service: CoPilotService, name: "Test1") )
        
        var found = false
        let b = Browser(service: CoPilotService) { service in
            found = true
        }
        expect(found).toEventually(beTrue(), timeout: 5)
        expect(b.services.count) == 1
        
        found = false
        services.append( publish(service: CoPilotService, name: "Test2") )
        expect(found).toEventually(beTrue(), timeout: 5)
        expect(b.services.count) == 2
        
        var removed = false
        b.onRemove = { service in
            removed = true
        }
        services.removeAtIndex(0)
        expect(removed).toEventually(beTrue(), timeout: 5)
        expect(b.services.count) == 1
    }
    
    
    func test_resolve() {
        let publishedService = publish(service: CoPilotService, name: "Test")
        
        self.resolved = false
        let b = Browser(service: CoPilotService) { service in
            service.delegate = self
            service.resolveWithTimeout(1)
        }
        expect(self.resolved).toEventually(beTrue(), timeout: 2)
    }

}


extension BonjourTests: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        NSLog("### netServiceDidResolveAddress \(sender)")
        self.resolved = true
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        NSLog("### netService:didNotResolve \(errorDict)")
    }
    
    func netServiceDidStop(sender: NSNetService) {
        NSLog("### netServiceDidStop")
    }

}
