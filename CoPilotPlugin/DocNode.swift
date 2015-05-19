//
//  DocNode.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 19/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation
import FeinstrukturUtils


enum State {
    case Initial, InSync, InConflict
}


class DocNode {
    internal var state: State = .Initial
    internal var sendThrottle = Throttle(bufferTime: 5)
    internal var _document: Document
    internal var _onUpdate: UpdateHandler?

    var name: String
    var document: Document { return self._document }

    init(name: String, document: Document) {
        self.name = name
        self._document = document
    }

}


// MARK: Test extensions
extension DocNode {

    var test_document: Document {
        get { return self._document }
        set { self._document = newValue }
    }

}
