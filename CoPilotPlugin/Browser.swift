//
//  Browser.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class Browser: NSObject {
    private let browser: NSNetServiceBrowser
    private var services = NSMutableOrderedSet()
    var onFind: (NSNetService -> Void)?
    var onRemove: (NSNetService -> Void)?
    
    init(service: BonjourService, onFind: (NSNetService -> Void) = {_ in}) {
        self.browser = NSNetServiceBrowser()
        super.init()
        self.browser.delegate = self
        self.onFind = onFind
        self.browser.searchForServicesOfType(service.type, inDomain: service.domain)
    }
}

extension Browser: NSNetServiceBrowserDelegate {
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        self.services.addObject(aNetService)
        self.onFind?(aNetService)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        self.services.removeObject(aNetService)
        self.onRemove?(aNetService)
    }
}


// Service access
extension Browser {
    
    var count: Int {
        get {
            return self.services.count
        }
    }
    
    subscript(index: Int) -> NSNetService {
        return self.services[index] as! NSNetService
    }
    
}
