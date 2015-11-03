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


class RabbitSocket: Socket {
    let id: ConnectionId

    private var connection: Connection?
    private var channel: Channel?
    private var consumer: Consumer?
    private var exchange: Exchange?

    init(connectionId: ConnectionId) {
        self.id = connectionId
    }

    func open() {
        self.connection = self.connect()
        self.channel = self.connection?.openChannel()
        self.exchange = self.channel?.declareExchange("doc_exchange")
        let q = self.channel?.declareQueue(self.id)
        q?.bindToExchange("doc_exchange", bindingKey: self.id)
        self.onConnect?()
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
        let hostname = "dockerhost"
        let port = 5672
        let username = "guest"
        let password = "guest"
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        return c
    }
}
