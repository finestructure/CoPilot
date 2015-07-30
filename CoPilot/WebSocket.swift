//
//  WebSocket.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 30/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


let WebSocketDisconnectedNotification = "WebSocketDisconnectedNotification"


enum Message: CustomStringConvertible {
    case Text(String)
    case Data(NSData)
    init(_ string: String) { self = .Text(string) }
    init(_ data: NSData) { self = .Data(data) }
    var string: String? {
        switch self {
        case .Text(let s):
            return s
        case .Data:
            return nil
        }
    }
    var data: NSData? {
        switch self {
        case .Text:
            return nil
        case .Data(let d):
            return d
        }
    }
    var description: String {
        switch self {
        case .Text(let s):
            return ".Text (\(s))"
        case .Data:
            return ".Data (\(self.data!.length) bytes)"
        }
    }
}


class WebSocket: NSObject {
    let socket: PSWebSocket
    var lastMessage: Message?
    
    var onConnect: (Void -> Void)?
    var onDisconnect: (NSError? -> Void)?
    var onReceive: MessageHandler?


    convenience init(url: NSURL, onConnect: (Void -> Void)) {
        self.init(url: url)
        self.onConnect = onConnect
        self.socket.open()
    }


    init(url: NSURL) {
        let req = NSURLRequest(URL: url)
        self.socket = PSWebSocket.clientSocketWithRequest(req)
        super.init()
        self.socket.delegate = self
    }


    init(socket: PSWebSocket) {
        self.socket = socket
        super.init()
        self.socket.delegate = self
    }


    func send(message: Message) {
        switch message {
        case .Text(let s):
            self.socket.send(s)
        case .Data(let d):
            self.socket.send(d)
        }
    }


    var isOpen: Bool {
        return self.socket.readyState == .Open
    }


    func open() {
        self.socket.open()
    }


    func close() {
        self.socket.close()
    }

}

extension WebSocket: PSWebSocketDelegate {
    
    func webSocketDidOpen(webSocket: PSWebSocket!) {
        self.onConnect?()
    }
    

    func webSocket(webSocket: PSWebSocket!, didReceiveMessage message: AnyObject!) {
        if let s = message as? String {
            self.lastMessage = Message(s)
        } else if let d = message as? NSData {
            self.lastMessage = Message(d)
        }
        if let msg = self.lastMessage {
            self.onReceive?(msg)
        }
    }
    

    func webSocket(webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName(WebSocketDisconnectedNotification, object: self)
        self.onDisconnect?(nil)
    }
    

    func webSocket(webSocket: PSWebSocket!, didFailWithError error: NSError!) {
        NSNotificationCenter.defaultCenter().postNotificationName(WebSocketDisconnectedNotification, object: self)
        self.onDisconnect?(error)
    }

}
