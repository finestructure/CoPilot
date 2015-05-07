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
    private let server: Server
    private var timer: NSTimer?
    private var lastDoc: Document?
    
    init(name: String, service: BonjourService = CoPilotService, textProvider: TextProvider) {
        self.textProvider = textProvider
        self.server = {
            let s = Server(name: name, service: service)
            s.onConnect = { ws in
                let doc = Document(textProvider())
                let cmd = Command(initialize: doc)
                ws.send(cmd.serialize())
            }
            s.start()
            return s
        }()
        self.timer = nil
        super.init()
        let timer = NSTimer.scheduledTimerWithTimeInterval(PollInterval, target: self, selector: "pollProvider", userInfo: nil, repeats: true)
        self.timer = timer
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
                return Command(initialize: newDoc)
            } else {
                let changes = Changeset(source: self.lastDoc!, target: newDoc)
                return Command(update: changes)
            }
            }()
        
        self.server.broadcast(command.serialize())
        self.lastDoc = newDoc
    }
    
}

