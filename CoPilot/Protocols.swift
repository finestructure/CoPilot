//
//  Protocols.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 23/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


protocol Serializable {

    init?(data: NSData)

    func serialize() -> NSData

}


protocol DocumentUpdating {
    var onDocumentUpdate: DocumentUpdate? { get set }
    var onCursorUpdate: CursorUpdate? { get set }
    var onDisconnect: (NSError? -> Void)? { get set }
}


protocol ConnectedDocument: DocumentUpdating {
    var id: NSUUID { get }
    var selectionColor: NSColor { get }
    func update(newDocument: Document)
    func update(selection: Selection)
    func disconnect()
    var connections: [DisplayName] { get }
}


