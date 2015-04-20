//
//  Browser.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


let CoPilotService = BonjourService(domain: "local", type: "_copilot._tcp", port: 8137)


struct BonjourService {
    let domain: String
    let type: String
    let port: Int32
}


class Browser: NSObject {
    private let browser: NSNetServiceBrowser
    var onFind: (NSNetService -> Void)?
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
    }
}
