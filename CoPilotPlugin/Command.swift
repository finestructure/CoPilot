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
        if let type = decoder.decodeObjectForKey(EncodingKeys.TypName.rawValue) as? String,
           let data = decoder.decodeObjectForKey(EncodingKeys.Data.rawValue) as? NSData {
            switch type {
            case TypeNames.Initialize.rawValue:
                let doc = Document(data: data)
                self = .Initialize(doc)
            case TypeNames.Update.rawValue:
                let changes = Changeset(data: data)
                self = .Update(changes)
            default:
                self = .Undefined
            }
        } else {
            self = .Undefined
        }
    }
    
    func serialize() -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(self.typeName, forKey: EncodingKeys.TypName.rawValue)
        switch self {
        case .Initialize(let doc):
            archiver.encodeObject(doc.serialize(), forKey: EncodingKeys.Data.rawValue)
        case .Update(let changes):
            archiver.encodeObject(changes.serialize(), forKey: EncodingKeys.Data.rawValue)
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
    
    var changes: Changeset? {
        switch self {
        case .Update(let changes):
            return changes
        default:
            return nil
        }
    }
    
    private enum EncodingKeys: String {
        case TypName = "typeName"
        case Data = "data"
    }
    
    private enum TypeNames: String {
        case Undefined = "Undefined"
        case Initialize = "Initialize"
        case Update = "Update"
    }
    
    var typeName: String {
        switch self {
        case .Undefined:
            return TypeNames.Undefined.rawValue
        case .Initialize:
            return TypeNames.Initialize.rawValue
        case .Update:
            return TypeNames.Update.rawValue
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
