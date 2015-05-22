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

    init(_ range: NSRange) {
        self.range = range
    }

    init(position: Int, length: Int) {
        self.init(NSRange(location: position, length: length))
    }

    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let value = decoder.decodeObjectForKey("range") as! NSValue
        self.range = value.rangeValue
    }

    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        let value = NSValue(range: self.range)
        archiver.encodeObject(value, forKey: "range")
        archiver.finishEncoding()
        return data
    }

}