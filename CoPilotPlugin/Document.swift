//
//  Document.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 09/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias Hash = String


struct Document {

    let text: String

    var hash: Hash {
        return self.text.md5()!
    }


    init(_ text: String) {
        self.text = text
    }

}


extension Document: Serializable {

    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        self.text = decoder.decodeObjectForKey("text") as! String
    }


    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(self.text, forKey: "text")
        archiver.finishEncoding()
        return data
    }

}


extension Document: Printable {

    var description: String {
        return "Document (\(self.hash) \(self.text))"
    }

}

