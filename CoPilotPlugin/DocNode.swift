//
//  DocNode.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 19/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation
import FeinstrukturUtils


let CacheLimit = 10_000_000 // characters


class DocNode {
    internal var sendThrottle = Throttle(bufferTime: 0.5)
    internal let revisions = NSCache()
    internal var _document: Document {
        willSet {
            let key = self._document.hash
            let value = self._document.text as NSString
            self.revisions.setObject(value, forKey: key, cost: value.length)
        }
    }
    internal var _onUpdate: UpdateHandler?

    var name: String
    var document: Document { return self._document }


    init(name: String, document: Document) {
        self.name = name
        self._document = document
        self.revisions.totalCostLimit = CacheLimit
    }

    
    internal func commit(document: Document) {
        self._document = document
        self._onUpdate?(document)
    }

}


// MARK: Test extensions
extension DocNode {

    var test_document: Document {
        get { return self._document }
        set { self._document = newValue }
    }

}
