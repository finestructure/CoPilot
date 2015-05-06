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
    private let socket: WebSocket
    var document: Document?
    var onChange: ChangeHandler?
    
    init(url: NSURL, onChange: ChangeHandler = {_ in}) {
        self.socket = WebSocket(url: url)
        self.socket.onReceive = { msg in
            let cmd = Command(data: msg.data!)
            println("DocClient: \(cmd)")
            switch cmd {
            case .Initialize(let doc):
                self.document = doc
            case .Update(let changes):
                self.applyChanges(changes)
            case .Undefined:
                println("DocClient: ignoring undefined command")
            }
        }
        self.onChange = onChange
    }
    
    func applyChanges(changes: Changeset) {
        if let doc = self.document {
            let res = apply(doc, changes)
            if res.succeeded {
                self.document = res.value
                self.onChange?(self.document!)
            } else {
                println("DocClient: applying patch failed: \(res.error?.localizedDescription)")
            }
        }
    }
    
}
