//
//  DocumentService.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 30/07/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


typealias ConnectionId = String
typealias ClientHandler = (ConnectionId -> Void)


protocol DocumentService {

    func publish(name: String)
    func unpublish()
    var onPublished: (Void -> Void)? { get set }
    var onClientConnect: ClientHandler? { get set }
    var onClientDisconnect: ClientHandler? { get set }
    func broadcast(message: Message, except: [ConnectionId])
    func send(message: Message, receiver to: ConnectionId)

}

