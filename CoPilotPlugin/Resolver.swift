//
//  Foo.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 21/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias ResolutionHandler = (WebSocket -> Void)

class Resolver: NSObject {
    private let service: NSNetService
    var onResolve: ResolutionHandler?
    var resolved = false
    init(service: NSNetService, timeout: NSTimeInterval, onResolve: ResolutionHandler = {_ in}) {
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
        
        if let host = sender.hostName {
            let port = sender.port
            let url = NSURL(scheme: "ws", host: "\(host):\(port)", path: "/")
            let socket = WebSocket(url: url!)
            self.onResolve?(socket)
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        self.resolved = false
    }
    
    func netServiceDidStop(sender: NSNetService) {
        self.resolved = false
    }
    
}

