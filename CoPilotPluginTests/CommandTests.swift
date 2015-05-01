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

    func test_serialize_1() {
        let orig = Command(command: .Init, data: nil)
        let d = orig.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.command.rawValue) == 1
        expect(copy.data).to(beNil())
    }
    
    func test_serialize_2() {
        let orig = Command(command: .Patch, data: "foo".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
        let d = orig.serialize()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.command.rawValue) == 2
        expect(copy.data).toNot(beNil())
        let s = NSString(data: copy.data!, encoding: NSUTF8StringEncoding)
        expect(s) == "foo"
    }
    
    func test_serialize_undefined() {
        let d = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: d)
        archiver.encodeInteger(-1, forKey: "command")
        archiver.encodeObject(nil, forKey: "data")
        archiver.finishEncoding()
        expect(d).toNot(beNil())
        let copy = Command(data: d)
        expect(copy.command.rawValue) == 0
        expect(copy.data).to(beNil())
    }
    
}
