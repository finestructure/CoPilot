//
//  ConnectionManager.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


let DocumentPublishedNotification = "DocumentPublishedNotification"
let DocumentConnectedNotification = "DocumentConnectedNotification"
let DocumentDisconnectedNotification = "DocumentDisconnectedNotification"


class ConnectionManager {
    
    private static var published = [ConnectedEditor]()
    private static var subscribed = [ConnectedEditor]()
    
    
    static func published(filter: (ConnectedEditor -> Bool)) -> ConnectedEditor? {
        return self.published.filter(filter).first
    }
    
    
    static func subscribed(filter: (ConnectedEditor -> Bool)) -> ConnectedEditor? {
        return self.subscribed.filter(filter).first
    }
    
    
    static func connected(filter: (ConnectedEditor -> Bool)) -> ConnectedEditor? {
        return self.published.filter(filter).first ?? self.subscribed.filter(filter).first
    }
    
    
    static func isPublished(editor: Editor) -> Bool {
        return self.published.filter({ $0.editor == editor }).count > 0
    }
    
    
    static func isSubscribed(editor: Editor) -> Bool {
        return self.subscribed.filter({ $0.editor == editor }).count > 0
    }
    
    
    static func isConnected(editor: Editor) -> Bool {
        return self.isPublished(editor) || self.isSubscribed(editor)
    }
 
    
    static func publish(editor: Editor) -> ConnectedEditor {
        let name = "\(editor.document.displayName) @ \(NSHost.currentHost().localizedName!)"
        let doc = { Document(editor.textStorage.string) }
        let docServer = DocServer(name: name, document: doc())
        let connectedEditor = ConnectedEditor(editor: editor, document: docServer)
        self.published.append(connectedEditor)
        NSNotificationCenter.defaultCenter().postNotificationName(DocumentPublishedNotification, object: self)
        return connectedEditor
    }
    
    
    static func disconnect(editor: Editor) {
        if let conn = self.connected({ $0.editor == editor }) {
            conn.document.disconnect()
            self.published = self.published.filter({ $0.editor != editor })
            self.subscribed = self.subscribed.filter({ $0.editor != editor })
            NSNotificationCenter.defaultCenter().postNotificationName(DocumentDisconnectedNotification, object: self)
        }
    }
    
    
    static func subscribe(service: NSNetService, editor: Editor) -> ConnectedEditor {
        let client = DocClient(service: service, document: Document(editor.textStorage.string))
        let connectedEditor = ConnectedEditor(editor: editor, document: client)
        self.subscribed.append(connectedEditor)
        NSNotificationCenter.defaultCenter().postNotificationName(DocumentConnectedNotification, object: self)
        return connectedEditor
    }
    
    
    static func disconnectAll() {
        for c in self.published {
            c.document.disconnect()
        }
        for c in self.subscribed {
            c.document.disconnect()
        }
    }
    
}

