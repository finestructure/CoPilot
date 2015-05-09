//
//  DocClient.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias UpdateHandler = (Document -> Void)


class DocClient {

    private var socket: WebSocket?
    private var resolver: Resolver?
    private var _document: Document
    var document: Document {
        set {
            if let changes = Changeset(source: self._document, target: newValue) {
                self.socket?.send(Command(update: changes).serialize())
                self._document = newValue
            }
        }
        get {
            return _document
        }
    }
    var onUpdate: UpdateHandler?
    var clientId: String = "DocClient"


    init(service: NSNetService, document: Document) {
        self._document = document
        self.resolver = Resolver(service: service, timeout: 5)
        self.resolver!.onResolve = resolve
    }
    
    
    init(websocket: WebSocket, document: Document) {
        self._document = document
        self.resolve(websocket)
    }
    
    
    private func resolve(websocket: WebSocket) {
        websocket.onReceive = messageHandler({ self._document }) { _, doc in
            self._document = doc
            self.onUpdate?(doc)
        }
        self.socket = websocket
    }

}

