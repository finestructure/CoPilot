//
//  Selection.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 19/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


struct Selection {
    let range: NSRange
    let id: NSUUID

    init(_ range: NSRange, id: NSUUID) {
        self.range = range
        self.id = id
    }

    init(position: Int, length: Int, id: NSUUID) {
        self.init(NSRange(location: position, length: length), id: id)
    }

    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let value = decoder.decodeObjectForKey("range") as! NSValue
        self.range = value.rangeValue
        self.id = decoder.decodeObjectForKey("id") as! NSUUID
    }

    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        let value = NSValue(range: self.range)
        archiver.encodeObject(value, forKey: "range")
        archiver.encodeObject(self.id, forKey: "id")
        archiver.finishEncoding()
        return data
    }

}