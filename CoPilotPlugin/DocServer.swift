//
//  DocServer.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 05/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


func updateCommand(#oldDoc: Document, #newDoc: Document) -> Command? {
    if let changes = Changeset(source: oldDoc, target: newDoc) {
        return Command(update: changes)
    } else {
        return nil
    }
}


class DocServer: NSObject {
    
    private var server: Server! = nil
    private var _document: Document
    var document: Document {
        set {
            println("Server.document: \(self._document) -> \(newValue)")
            if let command = updateCommand(oldDoc: self._document, newDoc: newValue) {
                self.broadcast(command)
                self._document = newValue
            }
        }
        get {
            return _document
        }
    }
    var clients = [DocClient]()
    
    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self._document = document
        super.init()
        self.server = {
            let s = Server(name: name, service: service)
            s.onConnect = { ws in
                self.clients.append({
                    let client = DocClient(websocket: ws, document: self.document)
                    client.clientId = "S\(self.clients.count + 1)"
                    println("\(client.clientId): doc set to \(self.document)")
                    client.send(Command(document: self.document))
                    client.onChange = { doc in
                        println("Server.onChange: \(self.document) -> \(doc)")
                        if let changes = Changeset(source: self.document, target: doc) {
                            println("       changes: \(changes)")
                            let res = apply(self.document, changes)
                            if res.succeeded {
                                self.document = res.value!
                                self.broadcast(Command(update: changes), exclude: client)
                            } else {
                                println("DocServer: cannot apply client changes: \(res.error!.localizedDescription)")
                            }
                        }
                    }
                    return client
                    }()
                )
            }
            s.start()
            return s
            }()
    }
    
    
    deinit {
        self.stop()
    }
    
    
    func stop() {
        self.server.stop()
    }
    
    
    func broadcast(command: Command, exclude: DocClient? = nil) {
        println("Server: broadcasting \(command)")
        for c in clients.filter({ $0 != exclude }) {
            c.send(command)
        }
    }

}

