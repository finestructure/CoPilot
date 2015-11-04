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
            self.exchange = self.channel?.declareExchange(CoPilotExchange, type: .Fanout)
            let q = self.channel?.declareQueue(self.id)
            q?.bindToExchange(CoPilotExchange, bindingKey: self.id)
            self.onConnect?()
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
            self.consumer = self.channel?.consumer(self.id)
            // FIXME: this needs to be more than just a one-off
            Async.background {
                if let s = self.consumer?.pop() {
                    let msg = Message(s)
                    self.onReceive?(msg)
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
