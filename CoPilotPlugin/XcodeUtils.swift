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
        if  let editor = DTXcodeUtils.currentEditor(),
            let window = DTXcodeUtils.currentWindow() {
                return Editor(editor: editor, window: window)
        } else {
            return nil
        }
    }

    
    static func textStorage(editor: NSViewController) -> NSTextStorage {
        return DTXcodeUtils.textStorageForEditor(editor)
    }

    
    static func sourceCodeDocument(editor: NSViewController) -> NSDocument {
        return DTXcodeUtils.sourceCodeDocumentForEditor(editor)
    }

    
    static func sourceTextView(editor: NSViewController) -> NSTextView {
        return DTXcodeUtils.sourceTextViewForEditor(editor)
    }

}
