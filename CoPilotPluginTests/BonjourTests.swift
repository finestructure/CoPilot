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

    var browser: NSNetServiceBrowser!
    
    func test_publish() {
        var s: NSNetService!
        s = publish(CoPilotService)
        expect(s).toNot(beNil())
        
        var found: NSNetService!
        let delegate = BrowserDelegate(serviceFound: { service in
            found = service
        })
        self.browser = NSNetServiceBrowser()
        self.browser.delegate = delegate
        self.browser.searchForServicesOfType(CoPilotService.type, inDomain: CoPilotService.domain)

        expect(found).toEventuallyNot(beNil(), timeout: 5)
        expect(found.type) == "_copilot._tcp."
    }


}


class BrowserDelegate: NSObject, NSNetServiceBrowserDelegate {
    
    var serviceFound: (NSNetService -> Void)?
    
    init(serviceFound: (NSNetService -> Void)) {
        self.serviceFound = serviceFound
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        self.serviceFound?(aNetService)
    }
    
}


//extension BonjourTests: NSNetServiceDelegate {
//    
//    func netServiceDidResolveAddress(sender: NSNetService) {
//        NSLog("netServiceDidResolveAddress \(sender)")
//    }
//    
//    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
//        NSLog("netService:didNotResolve \(errorDict)")
//    }
//    
//    func netServiceDidStop(sender: NSNetService) {
//        NSLog("netServiceDidStop")
//    }
//
//}
