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
    var onFind: (NSNetService -> Void)?
    var onRemove: (NSNetService -> Void)?
    var services = Set<NSNetService>()
    
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
        self.services.insert(aNetService)
        self.onFind?(aNetService)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        self.services.remove(aNetService)
        self.onRemove?(aNetService)
    }
}
