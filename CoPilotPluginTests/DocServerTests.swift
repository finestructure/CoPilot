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
        let c = createClient()
        var doc: Document?
        c.onReceive = { msg in
            let cmd = Command(data: msg.data!)
            println(cmd)
            switch cmd {
            case .Initialize(let d):
                doc = d
            case .Update(let changes):
                if let d = doc {
                    let res = apply(d, changes)
                    if res.succeeded {
                        doc = res.value
                    } else {
                        println("applying patch failed: \(res.error?.localizedDescription)")
                    }
                }
            case .Undefined:
                println("received undefined command")
            }
            if let d = doc {
                println("###\n\(d.text)\n###")
            }
        }
        println("test file path:\n\(TestFilePath)")
        expect(doc?.text).toEventually(equal("quit"), timeout: 600)
    }
    
}

