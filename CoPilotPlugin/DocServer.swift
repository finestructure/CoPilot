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


func onDoc(documentProvider: DocumentProvider, update: UpdateHandler) -> MessageHandler {
    return { msg in
        let cmd = Command(data: msg.data!)
        switch cmd {
        case .Doc(let doc):
            update(doc)
        case .Update(let changes):
            let res = apply(documentProvider(), changes)
            if res.succeeded {
                update(res.value!)
            } else {
                println("messageHandler: applying patch failed: \(res.error!.localizedDescription)")
            }
        default:
            println("messageHandler: ignoring command: \(cmd)")
        }
    }
}

func onMsg(block: MessageHandler) -> MessageHandler {
    return { msg in
        block(msg)
    }
}


class DocServer: NSObject {
    
    private var server: Server! = nil
    private var _document: Document
    var document: Document {
        set {
            if let command = updateCommand(oldDoc: self._document, newDoc: newValue) {
                println("Server document changed: \(self._document) -> \(newValue)")
                self.server.broadcast(command.serialize())
                self._document = newValue
            }
        }
        get {
            return _document
        }
    }
    private var timer: NSTimer!
    private var docProvider: DocumentProvider!
    var onUpdate: UpdateHandler?

    init(name: String, service: BonjourService = CoPilotService, document: Document) {
        self._document = document
        super.init()
        self.server = {
            let s = Server(name: name, service: service)
            s.onConnect = { ws in
                // initialize client on connect
                let cmd = Command(document: self._document)
                ws.send(cmd.serialize())
                
                let m = onDoc({ self._document }, { doc in
                    self._document = doc
                    self.onUpdate?(doc)
                })
                ws.onReceive = onMsg { msg in
                    let cmd = Command(data: msg.data!)
                    switch cmd {
                    case .Update:
                        self.server.broadcast(msg.data!, exclude: ws)
                    default:
                        break
                    }
                    m(msg)
                }
                
//                ws.onReceive = { msg in
//                    let cmd = Command(data: msg.data!)
//                    switch cmd {
//                    case .Doc(let doc):
//                        self._document = doc
//                        self.onUpdate?(doc)
//                    case .Update(let changes):
//                        let res = apply(self._document, changes)
//                        if res.succeeded {
//                            self._document = res.value!
//                            self.server.broadcast(msg.data!, exclude: ws)
//                            self.onUpdate?(self.document)
//                        } else {
//                            println("applying patch failed: \(res.error!.localizedDescription)")
//                        }
//                    default:
//                        println("ignoring command: \(cmd)")
//                    }
//               }
            }
            s.start()
            return s
            }()
    }
    
    func poll(interval: NSTimeInterval = 0.5, docProvider: DocumentProvider) {
        self.docProvider = docProvider
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "updateDoc", userInfo: nil, repeats: true)
    }
    
    func updateDoc() {
        self.document = self.docProvider()
    }
    

    deinit {
        self.stop()
    }
    
    
    func stop() {
        self.server.stop()
    }

}

