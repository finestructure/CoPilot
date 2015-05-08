//
//  Server.swift
//  Fradio
//
//  Created by Sven Schmidt on 27/03/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class Server: NSObject {
    
    let server: PSWebSocketServer
    var netService: NSNetService!
    let bonjourService: BonjourService
    var isRunning = false
    let name: String
    let host: String?
    var onPublished: ((NSNetService) -> Void)?
    var onError: ((NSError!) -> Void)?
    var onConnect: ((WebSocket!) -> Void)?
    var sockets = [WebSocket]()
    
    init(name: String, service: BonjourService, host: String? = nil) {
        self.name = name
        self.bonjourService = service
        self.host = host
        self.server = PSWebSocketServer(host: host, port: UInt(service.port))
        super.init()
        self.server.delegate = self
    }
    
    deinit {
        self.stop()
    }
    
    func start() {
        NSLog("starting server...")
        self.publishService()
        self.server.start()
    }
    
    
    func stop() {
        NSLog("stopping server...")
        self.unpublishService()
        self.server.stop()
    }
    
    
    func broadcast(message: AnyObject, exclude: WebSocket? = nil) {
        for s in self.sockets.filter({ $0 != exclude }) {
            s.send(message)
        }
    }
    
}


// MARK: - Helpers
extension Server {
    
    func publishService() {
        if self.netService == nil {
            self.netService = publish(service: self.bonjourService, name: self.name)
            self.onPublished?(self.netService)
        }
    }

    
    func unpublishService() {
        self.netService?.stop()
    }

}


// MARK: - PSWebSocketServerDelegate
extension Server: PSWebSocketServerDelegate {
    
    func serverDidStart(server: PSWebSocketServer!) {
        NSLog("server started")
        self.isRunning = true
    }
    
    func serverDidStop(server: PSWebSocketServer!) {
        NSLog("server stopped")
        self.isRunning = false
    }
    
    func server(server: PSWebSocketServer!, acceptWebSocketWithRequest request: NSURLRequest!) -> Bool {
        return true
    }
    
    func server(server: PSWebSocketServer!, webSocketDidOpen webSocket: PSWebSocket!) {
        let socket = WebSocket(socket: webSocket)
        self.sockets.append(socket)
        self.onConnect?(socket)
    }
    
    func server(server: PSWebSocketServer!, webSocket: PSWebSocket!, didReceiveMessage message: AnyObject!) {
        NSLog("received message: \(message)")
    }
    
    func server(server: PSWebSocketServer!, webSocket: PSWebSocket!, didFailWithError error: NSError!) {
        self.sockets = self.sockets.filter { $0.socket != webSocket }
        self.onError?(error)
        NSLog("failed: \(error.localizedDescription)")
    }
    
    func server(server: PSWebSocketServer!, webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        self.sockets = self.sockets.filter { $0.socket != webSocket }
        NSLog("closed: \(code) \(reason) clean: \(wasClean)")
    }

}

