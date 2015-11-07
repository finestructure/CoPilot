//
//  RabbitSocket.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 03/11/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import Async
import HastyHare


let CoPilotExchange = "CoPilot-Fanout"
let Hostname = "dockerhost"
let Port = 5672
let Username = "guest"
let Password = "guest"


func exchangeNameForDocId(docId: ConnectionId) -> String {
    return "CoPilot-\(docId)"
}


class RabbitSocket: Socket {
    let docId: ConnectionId
    let _id = NSUUID()

    private var connection: Connection?
    private var channel: Channel?
    private var consumer: Consumer?
    private var exchange: Exchange?

    init(docId: ConnectionId) {
        self.docId = docId
    }

    var id: ConnectionId {
        return self._id.UUIDString
    }

    func open() {
        self.connection = self.connect()
        if self.connection?.connected ?? false {
            self.channel = self.connection?.openChannel()
            let exName = exchangeNameForDocId(self.docId)
            if let ex = self.channel?.declareExchange(exName, type: .Fanout) {
                self.exchange = ex
                let q = self.channel?.declareQueue(self.id)
                let success = q?.bindToExchange(ex, bindingKey: self.id) ?? false
                if !success {
                    // FIXME: Socket.open needs error handling signature
                    print("error: could not bind to exchange \(ex.name)")
                }
                self.onConnect?()
            } else {
                // FIXME: Socket.open needs error handling signature
                print("error: could not declase exchange \(exName)")
            }
        } else {
            // FIXME: Socket.open needs error handling signature
            print("error: not connected")
        }
    }

    func close() {
        self.channel = nil
        self.connection = nil
        self.onDisconnect?(nil)
    }

    func send(message: Message) {
        switch message {
        case .Text(let s):
            self.exchange?.publish(s, routingKey: self.id)
        case .Data(let d):
            self.exchange?.publish(d, routingKey: self.id)
        }
    }

    var onConnect: ConnectionHandler?
    var onDisconnect: ErrorHandler?
    var onReceive: MessageHandler? {
        didSet {
            Async.background {
                if let ch = self.channel {
                    self.consumer = {
                        let cons = ch.consumer(self.id)
                        cons.listen { d in
                            let msg = Message(d)
                            self.onReceive?(msg)
                        }
                        return cons
                    }()
                }
            }
        }
    }

    func connect() -> Connection {
        let c = Connection(host: Hostname, port: Port)
        c.login(Username, password: Password)
        return c
    }
    
}
