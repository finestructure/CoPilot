//
//  Resolver.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class Resolver: NSObject {
    private let service: NSNetService
    var onResolve: (NSNetService -> Void)?
    var resolved = false
    init(service: NSNetService, timeout: NSTimeInterval, onResolve: (NSNetService -> Void) = {_ in}) {
        self.service = service
        super.init()
        self.service.delegate = self
        self.onResolve = onResolve
        self.service.resolveWithTimeout(timeout)
    }
}


extension Resolver: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        self.resolved = true
        self.onResolve?(sender)
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        self.resolved = false
    }
    
    func netServiceDidStop(sender: NSNetService) {
        self.resolved = false
    }
    
}
