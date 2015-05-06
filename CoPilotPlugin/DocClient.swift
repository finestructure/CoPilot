//
//  DocClient.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias ChangeHandler = (Document -> Void)


class DocClient {
    private var socket: WebSocket?
    private var resolver: Resolver?
    var document: Document
    var onInitialize: ChangeHandler?
    var onChange: ChangeHandler?
    
    
    init(service: NSNetService, document: Document) {
        self.document = document
        self.resolver = Resolver(service: service, timeout: 5)
        self.resolver!.onResolve = resolve
    }
    
    
    init(url: NSURL, document: Document) {
        self.document = document
        let ws = WebSocket(url: url)
        self.resolve(ws)
    }
    
    
    func resolve(websocket: WebSocket) {
        websocket.onReceive = { msg in
            let cmd = Command(data: msg.data!)
            // TODO: remove
            println("DocClient: \(cmd)")
            switch cmd {
            case .Initialize(let doc):
                self.initializeDocument(doc)
            case .Update(let changes):
                self.applyChanges(changes)
            case .Undefined:
                println("DocClient: ignoring undefined command")
            }
        }
        self.socket = websocket
    }
    
    
    func initializeDocument(document: Document) {
        self.document = document
        self.onInitialize?(document)
    }
    
    
    func applyChanges(changes: Changeset) {
        let res = apply(self.document, changes)
        if res.succeeded {
            self.document = res.value!
            self.onChange?(self.document)
        } else {
            println("DocClient: applying patch failed: \(res.error?.localizedDescription)")
        }
    }
    
}
