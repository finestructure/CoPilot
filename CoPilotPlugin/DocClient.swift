//
//  DocClient.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class DocClient {

    private var socket: WebSocket?
    private var resolver: Resolver?
    private var _document: Document
    private var _onUpdate: UpdateHandler?
    
    var clientId: String = "DocClient"
    var document: Document { return self._document }

    init(service: NSNetService, document: Document) {
        self._document = document
        self.resolver = Resolver(service: service, timeout: 5)
        self.resolver!.onResolve = { websocket in
            websocket.onReceive = messageHandler({ self._document }) { _, doc in
                self._document = doc
                self._onUpdate?(doc)
            }
            self.socket = websocket
        }
    }

}


extension DocClient: ConnectedDocument {

    var onUpdate: UpdateHandler? {
        get { return self._onUpdate }
        set { self._onUpdate = newValue }
    }
    
    
    func update(newDocument: Document) {
        if let changes = Changeset(source: self._document, target: newDocument) {
            self.socket?.send(Command(update: changes).serialize())
            self._document = newDocument
        }
    }
    
    
    func disconnect() {
        self.socket?.close()
    }
    
}

