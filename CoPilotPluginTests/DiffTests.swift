//
//  DiffTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 18/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble


class DiffTests: XCTestCase {
    
    func test_computeDiff() {
        let d = computeDiff("foo2bar", "foobar")
        expect(d.count) == 3
        expect(d[0].operation) == Operation.DiffEqual
        expect(d[0].text) == "foo"
        expect(d[1].operation) == Operation.DiffDelete
        expect(d[1].text) == "2"
        expect(d[2].operation) == Operation.DiffEqual
        expect(d[2].text) == "bar"
    }
    
    
    func test_patches() {
        let res = computePatches("foo2bar", "foobar")
        expect(res.count) == 1
        let lines = res[0].description.componentsSeparatedByString("\n")
        expect(lines[0]) == "@@ -1,7 +1,6 @@"
        expect(lines[1]) == " foo"
        expect(lines[2]) == "-2"
        expect(lines[3]) == " bar"
        expect(res[0].start1) == 0
        expect(res[0].start2) == 0
        expect(res[0].length1) == 7
        expect(res[0].length2) == 6
    }
    
    
    func test_apply_String() {
        let p = computePatches("foo2bar", "foobar")
        let res = apply("foo2bar", p)
        expect(res.succeeded) == true
        expect(res.value!) == "foobar"
    }
    
    
    func test_apply_Document() {
        let source = Document("The quick brown fox jumps over the lazy dog")
        let newText = "The quick brown cat jumps over the lazy dog"
        let changeSet = Changeset(source: source, target: Document(newText))
        let res = apply(source, changeSet)
        expect(res.succeeded) == true
        expect(res.value!.text) == newText
    }
    
    
    func test_apply_Document_diverged() {
        let fox = Document("The quick brown fox jumps over the lazy dog")
        let cat = Document("The quick brown leopard jumps over the lazy dog")
        let change = Changeset(source: fox, target: cat)
        let source = Document("The quick brown horse jumps over the lazy dog")
        let res = apply(source, change)
        expect(res.succeeded) == true
        expect(res.value!.text) == "The quick brown leopard jumps over the lazy dog"
    }
    
    
    func test_apply_Document_conflict() {
        let fox = Document("The quick brown fox jumps over the lazy dog")
        let cat = Document("The quick brown leopard jumps over the lazy dog")
        let change = Changeset(source: fox, target: cat)
        let source = Document("The quick thing likes the lazy dog")
        let res = apply(source, change)
        expect(res.succeeded) == false
        expect(res.value).to(beNil())
    }
    
    
    func test_hash() {
        let doc = Document("The quick brown fox jumps over the lazy dog")
        expect(doc.hash) == "9e107d9d372bb6826bd81d3542a419d6".uppercaseString
    }
    
}
