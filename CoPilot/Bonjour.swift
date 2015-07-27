//
//  Bonjour.swift
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
    var description: String {
        return "\(domain):\(type):\(port)"
    }
}


func publish(service  service: BonjourService, name: String) -> NSNetService {
    let s = NSNetService(domain: service.domain, type: service.type, name: name, port: service.port)
    s.publish()
    //    NSLog("published \(name) - \(service)")
    return s
}

