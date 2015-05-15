//
//  DocClient.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


struct SimpleConnection: Connection {
    let displayName: String
}


class DocClient {

    enum State {
        case Initial, InSync, InConflict
    }
    
    private var state: State = .Initial
    private var socket: WebSocket?
    private var resolver: Resolver?
    private var connection: Connection?
    private var _document: Document
    private var _onUpdate: UpdateHandler?
    
    var name: String
    var document: Document { return self._document }

    init(name: String = "DocClient", service: NSNetService, document: Document) {
        self.name = name
        self._document = document
        self.resolver = Resolver(service: service, timeout: 5)
        self.resolver!.onResolve = { websocket in
            self.connection = SimpleConnection(displayName: service.name)
            self.socket = websocket
            websocket.onConnect = {
                self.socket?.send(Command(name: self.name))
            }
            websocket.onReceive = self.onReceive
        }
    }


    func onReceive(msg: Message) {
        let cmd = Command(data: msg.data!)
        switch cmd {
        case .Doc(let doc):
            switch self.state {
            case .Initial:
                self._document = doc
                self._onUpdate?(doc)
                self.state = .InSync
            case .InConflict:
                // compute diff
                if let changes = Changeset(source: self._document, target: doc) {
                    self.socket?.send(Command(update: changes))
                    self._document = doc
                    self.state = .InSync
                }
                // send it
            case .InSync:
                break
            }
        case .Update(let changes):
            let res = apply(self._document, changes)
            if res.succeeded {
                self._document = res.value!
                self._onUpdate?(res.value!)
                self.state = .InSync
            } else {
                println("messageHandler: applying patch failed: \(res.error!.localizedDescription)")
                self.state = .InConflict
                // request original document in order to re-sync
                self.socket?.send(Command.GetDoc)
            }
        default:
            println("messageHandler: ignoring command: \(cmd)")
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
            self.socket?.send(Command(update: changes))
            self._document = newDocument
        }
    }
    
    
    func disconnect() {
        self.socket?.close()
    }
 
    
    var connections: [Connection] {
        if let c = self.connection {
            return [c]
        } else {
            return [Connection]()
        }
    }
    
}


// MARK: Test extensions
extension DocClient {
    
    var test_document: Document {
        get { return self._document }
        set { self._document = newValue }
    }

}
