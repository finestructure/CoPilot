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
        let controller = NSViewController()
        let window = NSWindow()
        return Editor(controller: controller, window: window)
    }
    
    
    static func textStorage(controller: NSViewController) -> NSTextStorage? {
        return NSTextStorage()
    }
    
    
    static func sourceCodeDocument(controller: NSViewController) -> NSDocument? {
        return NSDocument()
    }
    
    
    static func sourceTextView(controller: NSViewController) -> NSTextView? {
        return NSTextView()
    }
    
}
