//
//  DocumentManager.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


typealias UpdateHandler = (Document -> Void)


protocol ConnectedDocument {
    var onUpdate: UpdateHandler? { get set }
    func update(newDocument: Document)
    func disconnect()
}


struct Editor {
    let window: NSWindow
    let document: NSDocument
    let textStorage: NSTextStorage
}


extension Editor: Equatable { }

func ==(lhs: Editor, rhs: Editor) -> Bool {
    return lhs.window == rhs.window
        && lhs.document == rhs.document
        && lhs.textStorage == rhs.textStorage
}


class ConnectedEditor {
    let editor: Editor
    var document: ConnectedDocument
    var observer: NSObjectProtocol! = nil
    var sendThrottle = Throttle(bufferTime: 0.5)
    
    init(editor: Editor, document: ConnectedDocument) {
        self.editor = editor
        self.document = document
        self.startObserving()
        self.setOnUpdate()
    }
    
    // NB: inlining this crashes the compiler (Version 6.3.1 (6D1002))
    private func startObserving() {
        self.observer = observe("NSTextStorageDidProcessEditingNotification", object: editor.textStorage) { _ in
            self.sendThrottle.execute {
                println("#### doc updated")
                self.document.update(Document(self.editor.textStorage.string))
            }
        }
    }
    
    // NB: inlining this crashes the compiler (Version 6.3.1 (6D1002))
    private func setOnUpdate() {
        // TODO: refine this by only replacing the changed text or at least keeping the caret in place
        self.document.onUpdate = { doc in
            self.editor.textStorage.replaceAll(doc.text)
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.observer)
    }
}

