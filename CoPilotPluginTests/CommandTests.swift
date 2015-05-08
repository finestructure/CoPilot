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

    func test_serialize_Doc() {
        let doc = Document("foo")
        let orig = Command(document: doc)
        let d = orig.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.description) == ".Doc"
        expect(copy.document?.text) == "foo"
    }

    func test_serialize_Update() {
        let doc1 = Document("foo")
        let doc2 = Document("bar")
        let changes = Changeset(source: doc1, target: doc2)
        let data = Command(update: changes!).serialize()
        expect(data).toNot(beNil())
        let copy = Command(data: data)
        expect(copy.typeName) == "Update"
        expect(copy.changes).toNot(beNil())
        let res = apply(doc1, copy.changes!)
        expect(res.succeeded) == true
        expect(res.value!.text) == "bar"
    }
    
    func test_serialize_Undefined() {
        let d = Command.Undefined.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.typeName) == "Undefined"
        expect(copy.document).to(beNil())
        expect(copy.changes).to(beNil())
    }
    
    func test_serialize_Version() {
        let d = Command(version: "hash").serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.description) == ".Version"
        expect(copy.version) == "hash"
        expect(copy.document).to(beNil())
        expect(copy.changes).to(beNil())
    }
    
    func test_serialize_GetDocument() {
        let d = Command.GetDoc.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.description) == ".GetDoc"
        expect(copy.document).to(beNil())
        expect(copy.changes).to(beNil())
        expect(copy.version).to(beNil())
    }
    
    func test_serialize_GetVersion() {
        let d = Command.GetVersion.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.description) == ".GetVersion"
        expect(copy.document).to(beNil())
        expect(copy.changes).to(beNil())
        expect(copy.version).to(beNil())
    }

}
