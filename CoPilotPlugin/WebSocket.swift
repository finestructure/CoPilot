//
//  WebSocket.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 30/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


enum Message {
    case Text(String)
    case Data(NSData)
    init(_ string: String) { self = .Text(string) }
    init(_ data: NSData) { self = .Data(data) }
    var string: String? {
        get {
            switch self {
            case .Text(let s):
                return s
            case .Data:
                return nil
            }
        }
    }
    var data: NSData? {
        get {
            switch self {
            case .Text:
                return nil
            case .Data(let d):
                return d
            }
        }
    }
}


class WebSocket: NSObject {
    let socket: PSWebSocket
    var lastMessage: Message?
    
    var onConnect: (Void -> Void)?
    var onReceive: (Message -> Void)?
    
    init(url: NSURL, onConnect: (Void -> Void) = {}) {
        self.onConnect = onConnect
        let req = NSURLRequest(URL: url)
        self.socket = PSWebSocket.clientSocketWithRequest(req)
        super.init()
        self.socket.delegate = self
        self.socket.open()
    }
    
    init(socket: PSWebSocket) {
        self.socket = socket
        super.init()
        self.socket.delegate = self
    }
    
    func send(message: AnyObject) {
        self.socket.send(message)
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
    }
    
    func webSocket(webSocket: PSWebSocket!, didFailWithError error: NSError!) {
    }
}
