//
//  Bonjour.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


let CoPilotBonjourService = BonjourService(domain: "local", type: "_copilot._tcp", port: 8137)


struct BonjourService {
    let domain: String
    let type: String
    let port: Int32

    var description: String {
        return "\(domain):\(type):\(port)"
    }

    func publish(name name: String) -> NSNetService {
        let s = NSNetService(domain: self.domain, type: self.type, name: name, port: self.port)
        s.publish()
        //        NSLog("published \(name) - \(self)")
        return s
    }
}

