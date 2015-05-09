//
//  DocServer.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 05/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


typealias MessageDocumentHandler = ((Message, Document) -> Void)


func messageHandler(documentProvider: DocumentProvider, update: MessageDocumentHandler) -> MessageHandler {
    return { msg in
        let cmd = Command(data: msg.data!)
        switch cmd {
        case .Doc(let doc):
            update(msg, doc)
        case .Update(let changes):
            let res = apply(documentProvider(), changes)
            if res.succeeded {
                update(msg, res.value!)
            } else {
                println("messageHandler: applying patch failed: \(res.error!.localizedDescription)")
            }
        default:
            println("messageHandler: ignoring command: \(cmd)")
        }
    }
}


class DocServer: NSObject {
    
    private var server: Server! = nil
    private var _document: Document
    var document: Document {
        set {
            if let changes = Changeset(source: self._document, target: newValue) {
                self.server.broadcast(Command(update: changes).serialize())
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
                
                ws.onReceive = messageHandler({ self._document }, { msg, doc in
                    self._document = doc
                    self.server.broadcast(msg.data!, exclude: ws)
                    self.onUpdate?(doc)
                })
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

