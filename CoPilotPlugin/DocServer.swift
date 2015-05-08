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
                self.server.broadcast(command.serialize())
                self._document = newValue
            }
        }
        get {
            return _document
        }
    }
    
    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self._document = document
        super.init()
        self.server = {
            let s = Server(name: name, service: service)
            s.onConnect = { ws in
                // initialize client on connect
                let cmd = Command(document: self._document)
                ws.send(cmd.serialize())
                
                ws.onReceive = { msg in
                    let cmd = Command(data: msg.data!)
                    let sid = "S\(s.sockets.count + 1)"
                    println("\(sid): received \(cmd)")
                    switch cmd {
                    case .Doc(let doc):
                        break // we don't allow client to override the master
                    case .Update(let changes):
                        let res = apply(self._document, changes)
                        if res.succeeded {
                            self._document = res.value!
                            println("\(sid): applyChanges: set doc to (\(self._document))")
                            println("\(sid): applyChanges: calling onChange (\(self._document))")
                        } else {
                            println("\(sid): applying patch failed: \(res.error!.localizedDescription)")
                        }
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
                        println("\(sid): ignoring undefined command")
                    }
               }
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

}

