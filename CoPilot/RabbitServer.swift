//
//  RabbitServer.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 03/11/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


class RabbitServer {

    let name: String
    let socket: RabbitSocket
    var _onPublished: (Void -> Void)?
    var _onClientConnect: ClientHandler?
    var _onClientDisconnect: ClientHandler?
    var _onReceive: MessageConnectionIdHandler?
    var _onError: ErrorHandler?

    init(name: String, connectionId: NSUUID) {
        self.name = name
        self.socket = RabbitSocket(connectionId: connectionId.UUIDString)
    }

}


extension RabbitServer: DocumentService {

    func publish(name: String) {
        // TODO: bind to header exchange with id
    }

    func unpublish() {
        // TODO: unbind from header exchange
    }

    func broadcast(message: Message, exceptIds: [ConnectionId]) {
        // TODO: send to header exchange with exceptId param
    }

    func send(message: Message, receiverId: ConnectionId) {
        // TODO: send to header exchange with receiverId param
    }

    func start() {
        print("starting RabbitServer")
        self.publish(self.name)
    }

    func stop() {
        print("stopping RabbitServer")
        self.unpublish()
        self.socket.close()
    }

    var onPublished: (Void -> Void)? {
        get { return self._onPublished }
        set { self._onPublished = newValue }
    }

    var onClientConnect: ClientHandler? {
        get { return self._onClientConnect }
        set { self._onClientConnect = newValue }
    }

    var onClientDisconnect: ClientHandler? {
        get { return self._onClientDisconnect }
        set { self._onClientDisconnect = newValue }
    }

    var onReceive: MessageConnectionIdHandler? {
        get { return self._onReceive }
        set { self._onReceive = newValue }
    }

    var onError: ErrorHandler? {
        get { return self._onError }
        set { self._onError = newValue }
    }

}
