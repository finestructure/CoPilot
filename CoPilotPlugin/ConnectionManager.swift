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
    
}

