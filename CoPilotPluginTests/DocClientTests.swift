//
//  DocClientTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 30/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble

typealias ChangeHandler = (Void -> Void)

class DocClient {
    private let service: NSNetService
    private let onChange: ChangeHandler
    init(service: NSNetService, onChange: ChangeHandler) {
        self.service = service
        self.onChange = onChange
    }
}


class DocClientTests: XCTestCase {

    func test1() {
        expect(1+2) == 3
    }
    
}
