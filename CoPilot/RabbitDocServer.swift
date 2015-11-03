//
//  RabbitDocServer.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 02/11/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import HastyHare


class RabbitDocServer: DocNode {

    private var server: DocumentService! = nil
    private var _connections = [ConnectionId: DisplayName]()

    override init(name: String, document: Document) {
        super.init(name: name, document: document)

        self.server = RabbitServer(connectionId: self.id)

        self.server.onClientConnect = { clientId in
            self.resetClient(clientId)
        }
        self.server.onClientDisconnect = { clientId in
            self._connections.removeValueForKey(clientId)
        }
        self.server.onReceive = self.onReceive()
        self.server.onError = { error in
            self.onDisconnect?(error)
        }
        self.server.start()
    }


    func onReceive() -> MessageConnectionIdHandler {
        return { msg, clientId in
            guard let data = msg.data else {
                print("message does not contain data")
                return
            }

            let cmd = Command(data: data)
            // println("#### server cmd: \(cmd)")
            switch cmd {
            case .Doc:
                print("server not accepting .Doc commands")
            case .Update(let changes):
                // println("#### update:\n    doc:     \(self._document.hash)\n    baseRev: \(changes.baseRev)")
                let res = apply(self._document, changeSet: changes)
                if res.succeeded {
                    self.commit(res.value!)
                    self.server.broadcast(msg, exceptIds: [clientId])
                } else {
                    if let ancestor = self.revisions.objectForKey(changes.baseRev) as? String {
                        let mine = self._document.text
                        let res = apply(ancestor, patches: changes.patches)
                        if let yours = res.value,
                            let merged = merge(mine, ancestor: ancestor, yours: yours) {
                                self.commit(Document(merged))
                        } else {
                            self.resetClient(clientId)
                        }
                    } else { // instead of sending an override we could also request the rev from the other side's cache
                        self.resetClient(clientId)
                    }
                }
            case .GetDoc:
                let cmd = Command(document: self._document)
                self.server.send(Message(cmd.serialize()), receiverId: clientId)
            case .Name(let name):
                self._connections[clientId] = name
            case .Cursor(let selection):
                self._onCursorUpdate?(selection)
                self.server.broadcast(msg, exceptIds: [clientId])
            default:
                print("messageHandler: ignoring command: \(cmd)")
            }
        }
    }


    func resetClient(clientId: ConnectionId) {
        // send Doc to force resync - server wins
        let cmd = Command(document: self._document)
        self.server.send(Message(cmd.serialize()), receiverId: clientId)
    }


    func stop() {
        self.server.stop()
    }

}


extension RabbitDocServer: DocumentConnectable {

    func update(newDocument: Document) {
        if let _ = Changeset(source: self._document, target: newDocument) {
            if let changes = Changeset(source: self._document, target: newDocument) {
                self.docThrottle.execute {
                    self._document = newDocument
                    self.server.broadcast(Command(update: changes))
                }
            }
        }
    }


    func update(selection: Selection) {
        self.selThrottle.execute {
            self.server.broadcast(Command(selection: selection))
        }
    }


    func disconnect() {
        self.server.stop()
    }


    var connections: [DisplayName] {
        return Array(self._connections.values)
    }
    
}


