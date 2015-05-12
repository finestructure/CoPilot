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


protocol DocumentManager {
    var onUpdate: UpdateHandler? { get set }
    func update(newDocument: Document)
}


struct Editor {
    let controller: NSViewController
    let document: NSDocument
    let textStorage: NSTextStorage
}


extension Editor: Equatable { }

func ==(lhs: Editor, rhs: Editor) -> Bool {
    return lhs.controller == rhs.controller
        && lhs.document == rhs.document
        && lhs.textStorage == rhs.textStorage
}


class ConnectedEditor {
    let editor: Editor
    var documentManager: DocumentManager
    var observer: NSObjectProtocol! = nil
    var sendThrottle = Throttle(bufferTime: 0.5)
    
    init(editor: Editor, documentManager: DocumentManager) {
        self.editor = editor
        self.documentManager = documentManager
        self.startObserving()
        self.setOnUpdate()
    }
    
    // NB: inlining this crashes the compiler (Version 6.3.1 (6D1002))
    private func startObserving() {
        self.observer = observe("NSTextStorageDidProcessEditingNotification", object: editor.textStorage) { _ in
            self.sendThrottle.execute {
                println("#### doc updated")
                self.documentManager.update(Document(self.editor.textStorage.string))
            }
        }
    }
    
    // NB: inlining this crashes the compiler (Version 6.3.1 (6D1002))
    private func setOnUpdate() {
        // TODO: refine this by only replacing the changed text or at least keeping the caret in place
        self.documentManager.onUpdate = { doc in
            self.editor.textStorage.replaceAll(doc.text)
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.observer)
    }
}


func publishEditor(editor: Editor) -> ConnectedEditor {
    let name = "\(editor.document.displayName) @ \(NSHost.currentHost().localizedName!)"
    let doc = { Document(editor.textStorage.string) }
    let docServer = DocServer(name: name, document: doc())
    return ConnectedEditor(editor: editor, documentManager: docServer)
}


func connectService(service: NSNetService, editor: Editor) -> ConnectedEditor {
    let client = DocClient(service: service, document: Document(editor.textStorage.string))
    return ConnectedEditor(editor: editor, documentManager: client)
}

