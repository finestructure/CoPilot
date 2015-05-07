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
            println("DocClient: \(cmd)")
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
                println("DocClient: ignoring undefined command")
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
            self.onChange?(self._document)
        } else {
            println("DocClient: applying patch failed: \(res.error!.localizedDescription)")
        }
    }
    
    
    func send(command: Command) {
        self.socket?.send(command.serialize())
    }
    
}
