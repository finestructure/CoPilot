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
import FeinstrukturUtils


func pathForResource(#name: String, #type: String) -> String {
    let bundle = NSBundle(forClass: DiffTests.classForCoder())
    return bundle.pathForResource(name, ofType: type)!
}


func contentsOfFile(#name: String, #type: String) -> String {
    var result: NSString?
    if let error = try({ error in
        let path = pathForResource(name: name, type: type)
        result = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
        return
    }) {
        fail("failed to load test file: \(error.localizedDescription)")
    }
    return result! as String
}


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
        
        let p = res[0]
        expect(p.diffs.count) == 3
        expect(p[0].operation) == Operation.DiffEqual
        expect(p[0].text) == "foo"
        expect(p[1].operation) == Operation.DiffDelete
        expect(p[1].text) == "2"
        expect(p[2].operation) == Operation.DiffEqual
        expect(p[2].text) == "bar"
    }
    
    
    func test_patches_long() {
        let a = contentsOfFile(name: "test_a", type: "txt")
        let b = contentsOfFile(name: "test_b", type: "txt")
        let patches = computePatches(a, b)
        expect(patches.count) == 4
        
        var p = patches[0]
        expect(p.start1) == 0
        expect(p.start2) == 0
        expect(p.length1) == 108
        expect(p.length2) == 4
        
        expect(p.diffs.count) == 2
        expect(p[0].operation) == Operation.DiffDelete
        expect(p[0].text) == "The Way that can be told of is not the eternal Way;\nThe name that can be named is not the eternal name.\n"
        expect(count(p[0].text)) == 104
        expect(p[1].operation) == Operation.DiffEqual
        expect(p[1].text) == "The "
        expect(count(p[1].text)) == 4
        
        p = patches[1]
        expect(p.start1) == 44
        expect(p.start2) == 44
        expect(p.length1) == 17
        expect(p.length2) == 17

        expect(p.diffs.count) == 4
        expect(p[0].operation) == Operation.DiffEqual
        expect(p[0].text) == "th;\nThe "
        expect(count(p[0].text)) == 8
        expect(p[1].operation) == Operation.DiffDelete
        expect(p[1].text) == "N"
        expect(count(p[1].text)) == 1
        expect(p[2].operation) == Operation.DiffInsert
        expect(p[2].text) == "n"
        expect(count(p[2].text)) == 1
        expect(p[3].operation) == Operation.DiffEqual
        expect(p[3].text) == "amed is "
        expect(count(p[3].text)) == 8
        
        p = patches[2]
        expect(p.start1) == 83
        expect(p.start2) == 83
        expect(p.length1) == 8
        expect(p.length2) == 9
        
        expect(p.diffs.count) == 3
        expect(p[0].operation) == Operation.DiffEqual
        expect(p[0].text) == "gs.\n"
        expect(count(p[0].text)) == 4
        expect(p[1].operation) == Operation.DiffInsert
        expect(p[1].text) == "\n"
        expect(count(p[1].text)) == 1
        expect(p[2].operation) == Operation.DiffEqual
        expect(p[2].text) == "Ther"
        expect(count(p[2].text)) == 4
        
        p = patches[3]
        expect(p.start1) == 293
        expect(p.start2) == 293
        expect(p.length1) == 4
        expect(p.length2) == 101
        
        expect(p.diffs.count) == 2
        expect(p[0].operation) == Operation.DiffEqual
        expect(p[0].text) == "es.\n"
        expect(count(p[0].text)) == 4
        expect(p[1].operation) == Operation.DiffInsert
        expect(p[1].text) == "They both may be called deep and profound.\nDeeper and more profound,\nThe door of all subtleties!\n"
        expect(count(p[1].text)) == 97
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
        let res = apply(source, changeSet!)
        expect(res.succeeded) == true
        expect(res.value!.text) == newText
    }
    
    
    func test_apply_Document_diverged() {
        let fox = Document("The quick brown fox jumps over the lazy dog")
        let cat = Document("The quick brown leopard jumps over the lazy dog")
        let change = Changeset(source: fox, target: cat)
        let source = Document("The quick brown horse jumps over the lazy dog")
        let res = apply(source, change!)
        expect(res.succeeded) == true
        expect(res.value!.text) == "The quick brown leopard jumps over the lazy dog"
    }
    
    
    func test_apply_Document_conflict() {
        let fox = Document("The quick brown fox jumps over the lazy dog")
        let cat = Document("The quick brown leopard jumps over the lazy dog")
        let change = Changeset(source: fox, target: cat)
        let source = Document("The quick thing likes the lazy dog")
        let res = apply(source, change!)
        expect(res.succeeded) == false
        expect(res.value).to(beNil())
    }
    
    
    func test_apply_error() {
        let clientDoc = Document(contentsOfFile(name: "new_playground", type: "txt"))
        let serverDoc = Document("foo")
        let changes = Changeset(source: serverDoc, target: Document("foobar"))
        let res = apply(clientDoc, changes!)
        expect(res.succeeded) == false
        expect(res.error).toNot(beNil())
        expect(res.error?.localizedDescription) == "The operation couldn’t be completed. (Diff error 100.)"
    }
    
    
    func test_hash() {
        let doc = Document("The quick brown fox jumps over the lazy dog")
        expect(doc.hash) == "9e107d9d372bb6826bd81d3542a419d6".uppercaseString
    }
    
}
