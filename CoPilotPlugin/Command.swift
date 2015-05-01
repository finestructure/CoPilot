//
//  Command.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


enum Command {
    
    case Undefined
    case Initialize(Document)
    case Update(Changeset)
    
    init(initialize document: Document) {
        self = .Initialize(document)
    }

    init(update changes: Changeset) {
        self = .Update(changes)
    }
    
    init(data: NSData) {
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let obj: AnyObject? = decoder.decodeObjectForKey("data")
        if let doc = obj as? Document {
            self = .Initialize(doc)
        } else if let changes = obj as? Changeset {
            self = .Update(changes)
        } else {
            self = .Undefined
        }
    }
    
    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        switch self {
        case .Initialize(let doc):
            archiver.encodeObject((doc as! AnyObject), forKey: "data")
        case .Update(let changes):
            archiver.encodeObject((changes as! AnyObject), forKey: "data")
        default: break
        }
        archiver.finishEncoding()
        return data
    }
    
    var document: Document? {
        switch self {
        case .Initialize(let doc):
            return doc
        default:
            return nil
        }
    }
    
}


extension Command: Printable {
    
    var description: String {
        switch self {
        case .Undefined:
            return ".Undefined"
        case .Initialize:
            return ".Initialize"
        case .Update:
            return ".Update"
        }
    }
    
}
