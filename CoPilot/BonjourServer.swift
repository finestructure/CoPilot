//
//  Server.swift
//  Fradio
//
//  Created by Sven Schmidt on 27/03/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation


class BonjourServer: NSObject {
    
    let server: PSWebSocketServer
    var netService: NSNetService!
    let bonjourService: BonjourService
    var isRunning = false
    let name: String
    let host: String?
    var sockets = [WebSocket]()

    // backing store for DocumentService protocol
    var _onPublished: (Void -> Void)?
    var _onClientConnect: ClientHandler?
    var _onClientDisconnect: ClientHandler?
    var _onReceive: MessageConnectionIdHandler?
    var _onError: (NSError -> Void)?

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
        self.publish(self.name)
        self.server.start()
    }
    
    
    func stop() {
        NSLog("stopping server...")
        self.unpublish()
        self.server.stop()
    }
    
}


// MARK: - DocumentService
extension BonjourServer: DocumentService {

    func publish(name: String) {
        if self.netService == nil {
            self.netService = self.bonjourService.publish(name: name)
            self.onPublished?()
        }
    }


    func unpublish() {
        self.netService?.stop()
    }


    func broadcast(message: Message, exceptIds: [ConnectionId] = []) {
        for s in self.sockets.filter({ !exceptIds.contains($0.id) }) {
            s.send(message)
        }
    }

    
    func send(message: Message, receiverId: ConnectionId) {
        self.sockets.first{ $0.id == receiverId }?.send(message)
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


// MARK: - PSWebSocketServerDelegate
extension BonjourServer: PSWebSocketServerDelegate {
    
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
        self.onClientConnect?(socket.id)
        socket.onReceive = { msg in
            self.onReceive?(msg, socket.id)
        }
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

