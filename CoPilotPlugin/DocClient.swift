//
//  DocClient.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias ChangeHandler = (Document -> Void)


class DocClient: NSObject {
    private var socket: WebSocket?
    private var resolver: Resolver?
    private var _document: Document
    var document: Document {
        set {
            if let command = updateCommand(oldDoc: self._document, newDoc: newValue) {
                println("\(self.clientId): document: \(self._document) -> \(newValue)")
                self.send(command)
                self._document = newValue
            }
        }
        get {
            return _document
        }
    }
    var onInitialize: ChangeHandler?
    var onChange: ChangeHandler?
    var clientId: String = "DocClient"
    
    init(service: NSNetService, document: Document) {
        self._document = document
        self.resolver = Resolver(service: service, timeout: 5)
        super.init()
        self.resolver!.onResolve = resolve
    }
    
    
    init(websocket: WebSocket, document: Document) {
        self._document = document
        super.init()
        self.resolve(websocket)
    }
    
    
    func resolve(websocket: WebSocket) {
        websocket.onReceive = { msg in
            let cmd = Command(data: msg.data!)
            // TODO: remove
            println("\(self.clientId): received \(cmd)")
            switch cmd {
            case .Doc(let doc):
                self.initializeDocument(doc)
            case .Update(let changes):
                self.applyChanges(changes)
            case .Version(let version):
                // TODO: handle remote version event
                break
            case .GetDoc:
                // TODO: handle remote get doc event
                break
            case .GetVersion:
                // TODO: handle remote get version event
                break
            case .Undefined:
                println("\(self.clientId): ignoring undefined command")
            }
        }
        self.socket = websocket
    }
    
    
    func initializeDocument(document: Document) {
        self._document = document
        self.onInitialize?(document)
    }
    
    
    func applyChanges(changes: Changeset) {
        let res = apply(self._document, changes)
        if res.succeeded {
            self._document = res.value!
            println("\(self.clientId): applyChanges: set doc to (\(self._document))")
            println("\(self.clientId): applyChanges: calling onChange (\(self._document))")
            self.onChange?(self._document)
        } else {
            println("\(self.clientId): applying patch failed: \(res.error!.localizedDescription)")
        }
    }
    
    
    func send(command: Command) {
        println("\(self.clientId): sending \(command)")
        self.socket?.send(command.serialize())
    }
    
}
