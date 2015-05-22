//
//  Cursor.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 22/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


class Cursor: NSObject {

    let view = NSView()
    let anim = NSViewAnimation()
    let textView: NSTextView

    var selection: Selection = Selection(position: 0, length: 0) {
        didSet {
            if let rect = self.textView.rectForRange(selection.range) {
                self.view.frame = rect.withPadding(x: 1, y: 1)
            }
        }
    }

    init(color: NSColor, textView: NSTextView) {
        self.textView = textView
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = color.CGColor
        self.textView.addSubview(self.view)
    }

}

