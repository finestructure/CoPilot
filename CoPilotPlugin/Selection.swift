//
//  Selection.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 19/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


struct Selection {
    
    let range: NSRange
    let id: NSUUID
    let color: NSColor

    init(_ range: NSRange, id: NSUUID, color: NSColor) {
        self.range = range
        self.id = id
        self.color = color
    }

}


extension Selection: Serializable {

    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let value = decoder.decodeObjectForKey("range") as! NSValue
        self.range = value.rangeValue
        self.id = decoder.decodeObjectForKey("id") as! NSUUID
        self.color = decoder.decodeObjectForKey("color") as! NSColor
    }


    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        let value = NSValue(range: self.range)
        archiver.encodeObject(value, forKey: "range")
        archiver.encodeObject(self.id, forKey: "id")
        archiver.encodeObject(self.color, forKey: "color")
        archiver.finishEncoding()
        return data
    }

}