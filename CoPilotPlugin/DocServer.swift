//
//  DocServer.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 05/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


class DocServer {
    
    private var server: Server! = nil
    private var _document: Document
    private var _onUpdate: UpdateHandler?
    private var _connections = [WebSocket: Connection]()

    var document: Document { return self._document }

    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self._document = document
        self.server = Server(name: name, service: service)
        self.server.onConnect = { ws in
            // initialize client on connect
            let cmd = Command(document: self._document)
            ws.send(cmd.serialize())

            ws.onReceive = self.onReceive(ws)
        }
        self.server.start()
    }


    func onReceive(websocket: WebSocket) -> MessageHandler {
        return { msg in
            let cmd = Command(data: msg.data!)
            switch cmd {
            case .Doc(let doc):
                println("server not accepting .Doc commands")
            case .Update(let changes):
                let res = apply(self._document, changes)
                if res.succeeded {
                    self._document = res.value!
                    self.server.broadcast(msg.data!, exclude: websocket)
                    self.onUpdate?(res.value!)
                } else {
                    println("messageHandler: applying patch failed: \(res.error!.localizedDescription)")
                }
            case .Name(let name):
                self._connections[websocket] = SimpleConnection(displayName: name)
            default:
                println("messageHandler: ignoring command: \(cmd)")
            }
        }
   }


    func stop() {
        self.server.stop()
    }

}


extension DocServer: ConnectedDocument {

    var onUpdate: UpdateHandler? {
        get { return self._onUpdate }
        set { self._onUpdate = newValue }
    }
    
    
    func update(newDocument: Document) {
        if let changes = Changeset(source: self._document, target: newDocument) {
            if let changes = Changeset(source: self._document, target: newDocument) {
                self.server.broadcast(Command(update: changes).serialize())
                self._document = newDocument
            }
        }
    }

    
    func disconnect() {
        self.server.stop()
    }    
    
    
    var connections: [Connection] {
        return self._connections.values.array
    }

}

