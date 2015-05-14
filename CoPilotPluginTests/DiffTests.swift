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
        expect(count(a)) == 400
        let b = contentsOfFile(name: "test_b", type: "txt")
        expect(count(b)) == 394
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
    
    
    func test_adjustPos() {
        let a = contentsOfFile(name: "test_a", type: "txt")
        let b = contentsOfFile(name: "test_b", type: "txt")
        let patches = computePatches(a, b)
        expect(patches.count) == 4

        
        
        // line starts and ends
        expect(newPosition(0, patches)) == 0
        expect(newPosition(52, patches)) == 0
        expect(newPosition(53, patches)) == 0
        expect(newPosition(104, patches)) == 0
        expect(newPosition(105, patches)) == 1
        
        // line starts and ends
        expect(newPosition(152, patches)) == 48
        expect(newPosition(153, patches)) == 49
        
        // around 'Named' -> 'named' change
        expect(a[155..<159]) == " Nam"
        expect(b[51..<55]) == " nam"
        expect(newPosition(155, patches)) == 51
        expect(newPosition(156, patches)) == 52
        expect(newPosition(157, patches)) == 53
        
        expect(a[186..<190]) == "ngs."
        expect(b[82..<86]) == "ngs."
        expect(newPosition(186, patches)) == 82
        expect(newPosition(187, patches)) == 83
        expect(newPosition(188, patches)) == 84
        expect(newPosition(189, patches)) == 85
        
        expect(a[190..<191]) == "\n"
        expect(b[86..<88]) == "\n\n"
        expect(newPosition(190, patches)) == 86
        
        expect(a[191..<193]) == "Th"
        expect(b[88..<90]) == "Th"
        expect(newPosition(191, patches)) == 88
        expect(newPosition(192, patches)) == 89
        expect(newPosition(189, patches)) == 86

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
    
    
    func test_preserve_position() {
        let cr = "\n"
        let line = "0123456789"
        let a = line + cr + line + cr + line
        expect(count(a)) == 32
        let b = line + cr + line + cr + "01234 56789"
        let patches = computePatches(a, b)
        expect(patches.count) == 1
        let p = patches[0]
        expect(p.start1) == 23
        expect(p.start2) == 23
        expect(p.length1) == 8
        expect(p.length2) == 9
        expect(newPosition(0, patches)) == 0
        expect(newPosition(5, patches)) == 5
        expect(newPosition(10, patches)) == 10
        expect(newPosition(15, patches)) == 15
        expect(newPosition(20, patches)) == 20
        expect(newPosition(25, patches)) == 25
        expect(newPosition(27, patches)) == 27
        expect(newPosition(28, patches)) == 29
        expect(newPosition(30, patches)) == 31
        expect(newPosition(32, patches)) == 33
    }
    
}
