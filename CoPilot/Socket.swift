//
//  Socket.swift
//  CoPilot
//
//  Created by Sven A. Schmidt on 07/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


protocol Socket {
    func open()
    func close()
    func send(message: Message)
    var id: ConnectionId { get }
    var onConnect: ConnectionHandler? { get set }
    var onDisconnect: ErrorHandler? { get set }
    var onReceive: MessageHandler? { get set }
}


extension Socket {
    func send(command: Command) {
        self.send(Message(command.serialize()))
    }
}

