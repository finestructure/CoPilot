//
//  DocServer.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 05/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


let PollInterval = 0.5

typealias TextProvider = (Void -> String)


class DocServer: NSObject {
    
    private let textProvider: TextProvider
    private var server: Server! = nil
    private var timer: NSTimer! = nil
    private var lastDoc: Document?
    private var clients = [DocClient]()
    
    init(name: String, service: BonjourService = CoPilotService, textProvider: TextProvider) {
        self.textProvider = textProvider
        super.init()
        self.server = {
            let s = Server(name: name, service: service)
            s.onConnect = { ws in
                let doc = Document(textProvider())
                self.clients.append({
                    let client = DocClient(websocket: ws, document: doc)
                    client.send(Command(document: doc))
                    return client
                    }()
                )
            }
            s.start()
            return s
        }()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(PollInterval, target: self, selector: "pollProvider", userInfo: nil, repeats: true)
    }

    
    deinit {
        self.stop()
    }
    
    
    func stop() {
        self.server.stop()
    }
    
    
    func pollProvider() {
        let newDoc = Document(self.textProvider())
        
        if newDoc.hash == self.lastDoc?.hash {
            return
        }
        
        let command: Command = {
            if self.lastDoc == nil {
                return Command(document: newDoc)
            } else {
                let changes = Changeset(source: self.lastDoc!, target: newDoc)
                return Command(update: changes)
            }
            }()
        
        self.broadcast(command)
        self.lastDoc = newDoc
    }
    
    
    func broadcast(command: Command) {
        for c in self.clients {
            c.send(command)
        }
    }
    
}

