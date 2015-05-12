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
        if  let controller = DTXcodeUtils.currentEditor(),
            let doc = DTXcodeUtils.currentSourceCodeDocument(),
            let textStorage = DTXcodeUtils.currentTextStorage() {
                return Editor(controller: controller, document: doc, textStorage: textStorage)
        } else {
            return nil
        }
    }
    
}
