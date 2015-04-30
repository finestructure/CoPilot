//
//  WebSocket.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 30/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class WebSocket: NSObject {
    let socket: PSWebSocket
    var onConnect: (Void -> Void)?
    init(url: NSURL, onConnect: (Void -> Void)) {
        self.onConnect = onConnect
        let req = NSURLRequest(URL: url)
        self.socket = PSWebSocket.clientSocketWithRequest(req)
        super.init()
        self.socket.delegate = self
        self.socket.open()
    }
}

extension WebSocket: PSWebSocketDelegate {
    
    func webSocketDidOpen(webSocket: PSWebSocket!) {
        self.onConnect?()
    }
    
    func webSocket(webSocket: PSWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: PSWebSocket!, didFailWithError error: NSError!) {
        
    }
}
