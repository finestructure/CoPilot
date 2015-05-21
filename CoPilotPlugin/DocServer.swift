//
//  DocServer.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 05/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


extension WebSocket {
    func send(command: Command) {
        self.send(command.serialize())
    }
}


extension Server {
    func broadcast(command: Command, exclude: WebSocket? = nil) {
        self.broadcast(command.serialize(), exclude: exclude)
    }
}


class DocServer: DocNode {
    
    private var server: Server! = nil
    private var _connections = [WebSocket: Connection]()

    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self.server = Server(name: name, service: service)

        super.init(name: name, document: document)

        self.server.onConnect = { ws in
            self.resetClient(ws)
            ws.onReceive = self.onReceive(ws)
        }
        self.server.start()
    }


    func onReceive(websocket: WebSocket) -> MessageHandler {
        return { msg in
            let cmd = Command(data: msg.data!)
            // println("#### server cmd: \(cmd)")
            switch cmd {
            case .Doc(let doc):
                println("server not accepting .Doc commands")
            case .Update(let changes):
                // println("#### update:\n    doc:     \(self._document.hash)\n    baseRev: \(changes.baseRev)")
                let res = apply(self._document, changes)
                if res.succeeded {
                    self.commit(res.value!)
                    self.server.broadcast(msg.data!, exclude: websocket)
                } else {
                    if let ancestor = self.revisions.objectForKey(changes.baseRev) as? String {
                        let mine = self._document.text
                        let res = apply(ancestor, changes.patches)
                        if let yours = res.value,
                           let merged = merge(mine, ancestor, yours) {
                            self.commit(Document(merged))
                        } else {
                            self.resetClient(websocket)
                        }
                    } else { // instead of sending an override we could also request the rev from the other side's cache
                        self.resetClient(websocket)
                    }
                }
            case .GetDoc:
                websocket.send(Command(document: self._document))
            case .Name(let name):
                self._connections[websocket] = SimpleConnection(displayName: name)
            default:
                println("messageHandler: ignoring command: \(cmd)")
            }
        }
    }


    func resetClient(websocket: WebSocket) {
        // send Doc to force resync - server wins
        println("#### resetting client")
        websocket.send(Command(document: self._document))
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
                self.sendThrottle.execute {
                    self._document = newDocument
                    self.server.broadcast(Command(update: changes))
                }
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


// MARK: Test extensions
extension DocServer {
    
    var test_server: Server { return self.server }
    
}

