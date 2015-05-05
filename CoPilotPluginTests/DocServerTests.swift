//
//  DocServerTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble
import FeinstrukturUtils


let words = [
    "this",
    "is",
    "some",
    "list",
    "of",
    "totally",
    "arbitrary",
    "words",
]


var TestFilePath: String {
    let bundle = NSBundle(forClass: DocServerTests.classForCoder())
    return bundle.pathForResource("testfile", ofType: "txt")!
}


func fileTextProvider() -> String {
    var result: NSString?
    if let error = try({ error in
        result = NSString(contentsOfFile: TestFilePath, encoding: NSUTF8StringEncoding, error: error)
        return
    }) {
        fail("failed to load test file: \(error.localizedDescription)")
    }
    return result! as String
}


class DocClient {
    private let socket: WebSocket
    private var document: Document?
    
    init(url: NSURL) {
        self.socket = WebSocket(url: url)
        self.socket.onReceive = { msg in
            let cmd = Command(data: msg.data!)
            println("DocClient: \(cmd)")
            switch cmd {
            case .Initialize(let doc):
                self.document = doc
            case .Update(let changes):
                self.applyChanges(changes)
            case .Undefined:
                println("DocClient: ignoring undefined command")
            }
       }
    }
    
    func applyChanges(changes: Changeset) {
        if let doc = self.document {
            let res = apply(doc, changes)
            if res.succeeded {
                self.document = res.value
            } else {
                println("DocClient: applying patch failed: \(res.error?.localizedDescription)")
            }
        }
    }
    
}


class DocServerTests: XCTestCase {

    var server: DocServer!
    
    override func tearDown() {
        self.server.stop()
    }
    
    func test_server() {
        self.server = DocServer(name: "foo", textProvider: {
            return randomElement(words)!
        })
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            messages.append(msg)
            let cmd = Command(data: msg.data!)
            println(cmd)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }
    
    
    func test_serve_file() {
        // manual test, open test file (path is print below) in editor and type 'quit'
        self.server = DocServer(name: "foo", textProvider: fileTextProvider)
        let client = DocClient(url: TestUrl)
        println("test file path:\n\(TestFilePath)")
        expect(client.document?.text).toEventually(equal("quit"), timeout: 600)
    }
    
}

