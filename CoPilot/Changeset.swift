//
//  Changeset.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 09/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


struct Changeset {

    let patches: [Patch]
    let baseRev: Hash
    let targetRev: Hash

    init?(source: Document, target: Document) {
        if source.hash == target.hash {
            return nil
        } else {
            self.patches = computePatches(source.text, b: target.text)
            self.baseRev = source.hash
            self.targetRev = target.hash
        }
    }

}


extension Changeset: Serializable {

    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        self.patches = decoder.decodeObjectForKey("patches") as! [Patch]
        self.baseRev = decoder.decodeObjectForKey("baseRev") as! Hash
        self.targetRev = decoder.decodeObjectForKey("targetRev") as! Hash
    }

    
    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(self.patches, forKey: "patches")
        archiver.encodeObject(self.baseRev, forKey: "baseRev")
        archiver.encodeObject(self.targetRev, forKey: "targetRev")
        archiver.finishEncoding()
        return data
    }

}


extension Changeset: CustomStringConvertible {

    var description: String {
        return "Changeset (\(self.baseRev) \(self.patches))"
    }

}

