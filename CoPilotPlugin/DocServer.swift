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


class DocServer {
    
    private var state: State = .Initial
    private var server: Server! = nil
    private var _document: Document
    private var _onUpdate: UpdateHandler?
    private var _connections = [WebSocket: Connection]()
    private var sendThrottle = Throttle(bufferTime: 5)

    var document: Document { return self._document }

    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self._document = document
        self.server = Server(name: name, service: service)
        self.server.onConnect = { ws in
            // initialize client on connect
            ws.send(Command(document: self._document))

            ws.onReceive = self.onReceive(ws)
        }
        self.server.start()
    }


    func onReceive(websocket: WebSocket) -> MessageHandler {
        return { msg in
            let cmd = Command(data: msg.data!)
            println("#### server cmd: \(cmd)")
            switch cmd {
            case .Doc(let doc):
                switch self.state {
                case .Initial:
                    println("server not accepting initial .Doc commands")
                case .InConflict:
                    // compute diff
                    println("#### .InConflict")
                    if let changes = Changeset(source: self._document, target: doc) {
                        println("#### changes: \(changes)")
                        websocket.send(Command(update: changes))
                    }
                    // send it
                case .InSync:
                    break
                }
            case .Update(let changes):
                let res = apply(self._document, changes)
                if res.succeeded {
                    self._document = res.value!
                    self.server.broadcast(msg.data!, exclude: websocket)
                    self.onUpdate?(res.value!)
                } else {
                    println("#### server: applying patch failed: \(res.error!.localizedDescription)")
                    self.state = .InConflict
                    // request full document in order to re-sync
                    websocket.send(Command.GetDoc)
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
                self._document = newDocument
                self.sendThrottle.execute {
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
    
    var test_document: Document {
        get { return self._document }
        set { self._document = newValue }
    }
    var test_server: Server { return self.server }
    
}

