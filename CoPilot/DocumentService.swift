//
//  DocumentService.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 30/07/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias ConnectionId = String
typealias ClientHandler = ConnectionId -> Void
typealias MessageConnectionIdHandler = (Message, ConnectionId) -> Void


protocol DocumentService {

    func publish(name: String)
    func unpublish()
    func broadcast(message: Message, exceptIds: [ConnectionId])
    func send(message: Message, receiverId: ConnectionId)
    func start()
    func stop()

    var onPublished: (Void -> Void)? { get set }
    var onClientConnect: ClientHandler? { get set }
    var onClientDisconnect: ClientHandler? { get set }
    var onReceive: MessageConnectionIdHandler? { get set }
    var onError: ErrorHandler? { get set }

}


extension DocumentService {
    func broadcast(command: Command, exceptIds: [ConnectionId] = []) {
        self.broadcast(Message(command.serialize()), exceptIds: exceptIds)
    }
}
