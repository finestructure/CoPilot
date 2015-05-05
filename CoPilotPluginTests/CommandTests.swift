//
//  CommandTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 01/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


class CommandTests: XCTestCase {

    func test_serialize_doc() {
        let doc = Document("foo")
        let orig = Command(initialize: doc)
        let d = orig.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.description) == ".Initialize"
        expect(copy.document?.text) == "foo"
    }

    func test_serialize_changes() {
        let doc1 = Document("foo")
        let doc2 = Document("bar")
        let changes = Changeset(source: doc1, target: doc2)
        let data = Command(update: changes).serialize()
        expect(data).toNot(beNil())
        let copy = Command(data: data)
        expect(copy.typeName) == "Update"
        expect(copy.changes).toNot(beNil())
        let res = apply(doc1, copy.changes!)
        expect(res.succeeded) == true
        expect(res.value!.text) == "bar"
    }
    
    func test_serialize_undefined() {
        let d = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: d)
        archiver.encodeObject(nil, forKey: "foo")
        archiver.finishEncoding()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.typeName) == "Undefined"
        expect(copy.document).to(beNil())
        expect(copy.changes).to(beNil())
    }
    
}
