//
//  DocumentManager.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


protocol Connection {
    var displayName: String { get }
}


typealias DocumentUpdate = (Document -> Void)
typealias CursorUpdate = (Selection -> Void)


protocol ConnectedDocument {
    var onDocumentUpdate: DocumentUpdate? { get set }
    var onCursorUpdate: CursorUpdate? { get set }
    func update(newDocument: Document)
    func update(selection: Selection)
    func disconnect()
    var connections: [Connection] { get }
}


struct Editor {
    let controller: NSViewController
    let window: NSWindow
    let textStorage: NSTextStorage
    let document: NSDocument
    
    init?(controller: NSViewController?, window: NSWindow?) {
        if  let controller = controller,
            let window = window,
            let ts = XcodeUtils.textStorage(controller),
            let doc = XcodeUtils.sourceCodeDocument(controller) {
                self.controller = controller
                self.window = window
                self.textStorage = ts
                self.document = doc
        } else {
            return nil
        }
    }
}


extension Editor: Equatable { }

func ==(lhs: Editor, rhs: Editor) -> Bool {
    return lhs.controller == rhs.controller
        && lhs.window == rhs.window
}


class ConnectedEditor {
    let editor: Editor
    var document: ConnectedDocument
    var observers = [NSObjectProtocol]()
    
    init(editor: Editor, document: ConnectedDocument) {
        self.editor = editor
        self.document = document
        self.startObserving()
        self.setOnUpdate()
    }
    

    private func startObserving() {
        self.observers.append(
            observe("NSTextStorageDidProcessEditingNotification", object: editor.textStorage) { _ in
                println("#### doc updated")
                self.document.update(Document(self.editor.textStorage.string))
            }
        )
        if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
            self.observers.append(
                observe("NSTextViewDidChangeSelectionNotification", object: tv) { _ in
                    let curserPos = Selection(tv.selectedRange)
                    self.document.update(curserPos)
                }
            )
        }

    }
    

    private func setOnUpdate() {
        // TODO: refine this by only replacing the changed text
        self.document.onDocumentUpdate = { newDoc in
            if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
                // TODO: this is not efficient - we've already computed this patch on the other side but it's difficult to route this through. We need to do this to preserve the insertion point. We could just send the Changeset instead of the Document and do it all here.
                let patches = computePatches(tv.string, newDoc.text)
                let selected = tv.selectedRange
                let currentPos = Position(selected.location)
                let newPos = newPosition(currentPos, patches)
                
                self.editor.textStorage.replaceAll(newDoc.text)
                
                // adjust the selection length so we don't select past the end
                let newSelection = adjustSelection(selected, newPos, newDoc.text)
                tv.setSelectedRange(newSelection)
            }
        }

        self.document.onCursorUpdate = { selection in
            if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
                print("remote pos: \(selection.range)")
            }
        }
    }
    
    
    deinit {
        for o in self.observers {
            NSNotificationCenter.defaultCenter().removeObserver(o)
        }
    }
}


func adjustSelection(selection: NSRange, newPosition: Position, newString: String) -> NSRange {
    let newLength = (newString as NSString).length
    let pos = min(Int(newPosition), newLength)
    let newSelection = NSRange(location: pos, length: selection.length)
    return newSelection
}

