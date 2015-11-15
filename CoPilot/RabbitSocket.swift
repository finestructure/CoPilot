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


class RabbitSocket {
    let docId: ConnectionId
    let _id = NSUUID()

    private var connection: Connection?
    private var channel: Channel?
    private var consumer: Consumer?
    private var exchange: Exchange?
    private var _onConnect: ConnectionHandler?
    private var _onDisconnect: ErrorHandler?
    private var _onReceive: MessageHandler?

    init(docId: ConnectionId) {
        self.docId = docId
    }

    func startConsuming() {
        Async.background {
            guard let ch = self.channel else {
                return
            }

            self.consumer = {
                let c = ch.consumer(self.id)
                c.listen { d in
                    let msg = Message(d)
                    self.onReceive?(msg)
                }
                return c
            }()
        }
    }

}


extension RabbitSocket: Socket {

    var id: ConnectionId {
        return self._id.UUIDString
    }

    func open() {
        self.connection = self.connect()
        if self.connection?.connected ?? false {
            self.channel = self.connection?.openChannel()
            let exName = exchangeNameForDocId(self.docId)
            if let ex = self.channel?.declareExchange(exName, type: .Fanout, autoDelete: true) {
                self.exchange = ex
                let q = self.channel?.declareQueue(self.id, exclusive: true)
                let success = q?.bindToExchange(ex, bindingKey: self.id) ?? false
                if success {
                    self.onConnect?()
                } else {
                    // FIXME: Socket.open needs error handling signature
                    print("error: could not bind to exchange \(ex.name)")
                }
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

    var onConnect: ConnectionHandler? {
        get { return self._onConnect }
        set { self._onConnect = newValue }
    }

    var onDisconnect: ErrorHandler? {
        get { return self._onDisconnect }
        set { self._onDisconnect = newValue }
    }

    var onReceive: MessageHandler? {
        get { return self._onReceive }
        set {
            self._onReceive = newValue
            self.startConsuming()
        }
    }

    func connect() -> Connection {
        let c = Connection(host: Hostname, port: Port)
        c.login(Username, password: Password)
        return c
    }

}
