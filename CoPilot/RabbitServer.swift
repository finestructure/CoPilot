//
//  RabbitServer.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 03/11/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


class RabbitServer {

    let socket: RabbitSocket
    var _onPublished: (Void -> Void)?
    var _onClientConnect: ClientHandler?
    var _onClientDisconnect: ClientHandler?
    var _onReceive: MessageConnectionIdHandler?
    var _onError: ErrorHandler?

    init(connectionId: NSUUID) {
        self.socket = RabbitSocket(connectionId: connectionId.UUIDString)
    }

}


extension RabbitServer: DocumentService {

    func publish(name: String) {}
    func unpublish() {}
    func broadcast(message: Message, exceptIds: [ConnectionId]) {}
    func send(message: Message, receiverId: ConnectionId) {}
    func start() {}
    func stop() {}

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
