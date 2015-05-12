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
        if  let window = DTXcodeUtils.currentWindow(),
            let doc = DTXcodeUtils.currentSourceCodeDocument(),
            let textStorage = DTXcodeUtils.currentTextStorage() {
                return Editor(window: window, document: doc, textStorage: textStorage)
        } else {
            return nil
        }
    }
    
}
