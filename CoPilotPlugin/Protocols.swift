//
//  Protocols.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 23/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


protocol Serializable {

    init?(data: NSData)

    func serialize() -> NSData

}

