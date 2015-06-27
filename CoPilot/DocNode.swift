//
//  DocNode.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 19/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


let CacheLimit = 10_000_000 // characters
let BufferTime: NSTimeInterval = 0.5

let Colors = [
    NSColor.blueColor(),
    NSColor.brownColor(),
    NSColor.greenColor(),
    NSColor.redColor(),
    NSColor.magentaColor(),
    NSColor.purpleColor(),
]


class DocNode {
    internal var docThrottle = Throttle(bufferTime: BufferTime)
    internal var selThrottle = Throttle(bufferTime: BufferTime)
    internal let revisions = NSCache()
    internal var _document: Document {
        willSet {
            let key = self._document.hash
            let value = self._document.text as NSString
            self.revisions.setObject(value, forKey: key, cost: value.length)
        }
    }
    internal var _onDocumentUpdate: DocumentUpdate?
    internal var _onCursorUpdate: CursorUpdate?
    internal var _onDisconnect: (NSError? -> Void)?

    var id = NSUUID()
    var name: String
    var selectionColor = randomElement(Colors)!
    var document: Document { return self._document }


    init(name: String, document: Document) {
        self.name = name
        self._document = document
        self.revisions.totalCostLimit = CacheLimit
    }

    
    internal func commit(document: Document) {
        self._document = document
        self._onDocumentUpdate?(document)
    }

}


extension DocNode: DocumentUpdating {

    var onDocumentUpdate: DocumentUpdate? {
        get { return self._onDocumentUpdate }
        set { self._onDocumentUpdate = newValue }
    }


    var onCursorUpdate: CursorUpdate? {
        get { return self._onCursorUpdate }
        set { self._onCursorUpdate = newValue }
    }


    var onDisconnect: (NSError? -> Void)? {
        get { return self._onDisconnect }
        set { self._onDisconnect = newValue }
    }

}


