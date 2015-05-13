//
//  XcodeUtils+mock.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 13/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


struct XcodeUtils {
    
    static var activeEditor: Editor? {
        let editor = NSViewController()
        let window = NSWindow()
        return Editor(editor: editor, window: window)
    }
    
    
    static func textStorage(editor: NSViewController) -> NSTextStorage? {
        return NSTextStorage()
    }
    
    
    static func sourceCodeDocument(editor: NSViewController) -> NSDocument? {
        return NSDocument()
    }
    
    
    static func sourceTextView(editor: NSViewController) -> NSTextView? {
        return NSTextView()
    }
    
}
