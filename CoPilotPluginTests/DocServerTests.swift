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


func fileTextProvider(path: String) -> (Void -> String) {
    return {
        var result: NSString?
        if let error = try({ error in
            result = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
            return
        }) {
            if error.code == 260 { // does not exist
                result = ""
                let res = try({ error in
                    result?.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: error)
                })
                if res.failed {
                    fail("could not create file: \(res.error!.localizedDescription)")
                }
            } else {
                fail("failed to load test file: \(error.localizedDescription)")
            }
        }
        return result! as String
    }
}


typealias ChangeHandler = (Document -> Void)

class DocClient {
    private let socket: WebSocket
    private var document: Document?
    private var onChange: ChangeHandler?
    
    init(url: NSURL, onChange: ChangeHandler = {_ in}) {
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
        self.onChange = onChange
    }
    
    func applyChanges(changes: Changeset) {
        if let doc = self.document {
            let res = apply(doc, changes)
            if res.succeeded {
                self.document = res.value
                self.onChange?(self.document!)
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
    
    
    func test_sync_files() {
        // manual test, open test files (path is print below) in editor and type to sync changes. Type 'quit' in master doc to quit test.
        self.server = DocServer(name: "foo", textProvider: fileTextProvider("/tmp/server.txt"))
        let client = DocClient(url: TestUrl) { doc in
            println("client doc: \(doc.text)")
            if try({ e in
                doc.text.writeToFile("/tmp/client.txt", atomically: true, encoding: NSUTF8StringEncoding, error: e)
            }).failed {
                println("writing file failed")
            }
        }
        expect(client.document?.text).toEventually(equal("quit"), timeout: 600)
    }
}

