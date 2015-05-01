//
//  Command.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


struct Command {
    
    enum Type: Int {
        case Undefined
        case Init
        case Patch
    }
    
    let command: Type
    let data: NSData?
    
    init(command: Type, data: NSData? = nil) {
        self.command = command
        self.data = data
    }
    
    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        self.command = Type(rawValue: decoder.decodeIntegerForKey("command")) ?? .Undefined
        self.data = decoder.decodeObjectForKey("data") as? NSData
    }
    
    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeInteger(self.command.rawValue, forKey: "command")
        archiver.encodeObject(self.data, forKey: "data")
        archiver.finishEncoding()
        return data
    }
}