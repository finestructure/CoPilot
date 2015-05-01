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

let PollInterval = 0.5

typealias TextProvider = (Void -> String)

class DocServer: NSObject {
    
    private let textProvider: TextProvider
    private let server: Server
    private var timer: NSTimer?
    private var lastDoc: Document?
    
    init(name: String, service: BonjourService = CoPilotService, textProvider: TextProvider) {
        self.textProvider = textProvider
        self.server = Server(name: name, service: service)
        self.server.start()
        self.timer = nil
        super.init()
        let timer = NSTimer.scheduledTimerWithTimeInterval(PollInterval, target: self, selector: "pollProvider", userInfo: nil, repeats: true)
        self.timer = timer
    }

    func pollProvider() {
        let newDoc = Document(self.textProvider())
        
        if newDoc.hash == self.lastDoc?.hash {
            return
        }
        
        let command: Command = {
            if self.lastDoc == nil {
                return Command(command: .Init, data: newDoc.data)
            } else {
                let changes = Changeset(source: self.lastDoc!, target: newDoc)
                return Command(command: .Changeset, data: changes.serialize())
            }
        }()

        self.server.broadcast(command.serialize())
        self.lastDoc = newDoc
    }
    
}


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


class DocServerTests: XCTestCase {

    func test_server() {
        let s = DocServer(name: "foo", textProvider: {
            return randomElement(words)!
        })
        let c = createClient()
        var messages = [Message]()
        c.onReceive = { msg in
            println(msg)
            messages.append(msg)
        }
        expect(messages.count).toEventually(beGreaterThan(1), timeout: 5)
    }
    
    
    func _test_serve_file() {
        // manual test, open test file in editor and type 'foobar'
        let s = DocServer(name: "foo", textProvider: fileTextProvider)
        let c = createClient()
        c.onReceive = { msg in
            if let s = msg.string {
                println("received: \(s)")
            }
        }
        println(TestFilePath)
        expect(c.lastMessage?.string).toEventually(equal("foobar"), timeout: 600)
    }
    
}

