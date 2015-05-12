//
//  ConnectionManager.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class ConnectionManager {
    
    static var published = [ConnectedEditor]()
    static var subscribed = [ConnectedEditor]()
    
    static func isPublished(editor: Editor) -> Bool {
        return self.published.filter({ $0.editor == editor }).count > 0
    }
 
    static func publish(editor: Editor) -> ConnectedEditor {
        let name = "\(editor.document.displayName) @ \(NSHost.currentHost().localizedName!)"
        let doc = { Document(editor.textStorage.string) }
        let docServer = DocServer(name: name, document: doc())
        let connectedEditor = ConnectedEditor(editor: editor, documentManager: docServer)
        self.published.append(connectedEditor)
        return connectedEditor
    }
    
}

