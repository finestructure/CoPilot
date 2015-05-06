//
//  DocClientServerTests.swift
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



class DocClientServerTests: XCTestCase {

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
        let client = DocClient(url: TestUrl, document: Document(""))
        client.onInitialize = { doc in
            println("client doc: \(doc.text)")
            if try({ e in
                doc.text.writeToFile("/tmp/client.txt", atomically: true, encoding: NSUTF8StringEncoding, error: e)
            }).failed {
                println("writing file failed")
            }
        }
        client.onChange = client.onInitialize
        expect(client.document.text).toEventually(equal("quit"), timeout: 600)
    }
    
    
    func test_init_nsNetService() {
        self.server = DocServer(name: "foo", textProvider: {
            return randomElement(words)!
        })
        var service: NSNetService!
        let browser = Browser(service: CoPilotService) { s in service = s }
        expect(service).toEventuallyNot(beNil(), timeout: 5)
        
        let client = DocClient(service: service, document: Document(""))
        var changeCount = 0
        client.onInitialize = { _ in
            changeCount++
        }
        client.onChange = client.onInitialize
        expect(changeCount).toEventually(beGreaterThan(0), timeout: 5)
    }
    
}

