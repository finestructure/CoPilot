//
//  XcodeUtils.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa


struct XcodeUtils {
    
    static var activeEditor: Editor? {
        return Editor(controller: DTXcodeUtils.currentEditor(), window: DTXcodeUtils.currentWindow())
    }

    
    static func textStorage(controller: NSViewController) -> NSTextStorage? {
        return DTXcodeUtils.textStorageForEditor(controller)
    }

    
    static func sourceCodeDocument(controller: NSViewController) -> NSDocument? {
        return DTXcodeUtils.sourceCodeDocumentForEditor(controller)
    }

    
    static func sourceTextView(controller: NSViewController) -> NSTextView? {
        return DTXcodeUtils.sourceTextViewForEditor(controller)
    }

}
