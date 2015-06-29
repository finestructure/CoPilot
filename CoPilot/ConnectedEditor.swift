//
//  DocumentManager.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 12/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


typealias DisplayName = String

typealias DocumentUpdate = (Document -> Void)
typealias CursorUpdate = (Selection -> Void)


protocol DocumentUpdating {
    var onDocumentUpdate: DocumentUpdate? { get set }
    var onCursorUpdate: CursorUpdate? { get set }
    var onDisconnect: (NSError? -> Void)? { get set }
}


protocol ConnectedDocument: DocumentUpdating {
    var id: NSUUID { get }
    var selectionColor: NSColor { get }
    func update(newDocument: Document)
    func update(selection: Selection)
    func disconnect()
    var connections: [DisplayName] { get }
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
    var connectedDocument: ConnectedDocument
    var observers = [NSObjectProtocol]()
    var cursors = [NSUUID: Cursor]()

    init(editor: Editor, connectedDocument: ConnectedDocument) {
        self.editor = editor
        self.connectedDocument = connectedDocument
        self.startObserving()
        self.setOnUpdate()
    }
    

    private func startObserving() {
        self.observers.append(
            observe("NSTextStorageDidProcessEditingNotification", object: editor.textStorage) { _ in
                self.connectedDocument.update(Document(self.editor.textStorage.string))
            }
        )
        if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
            self.observers.append(
                observe("NSTextViewDidChangeSelectionNotification", object: tv) { _ in
                    let curserPos = Selection(tv.selectedRange, id: self.connectedDocument.id, color: self.connectedDocument.selectionColor)
                    self.connectedDocument.update(curserPos)
                }
            )
        }

    }
    

    private func setOnUpdate() {
        // TODO: refine this by only replacing the changed text
        self.connectedDocument.onDocumentUpdate = { newDoc in
            if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
                // TODO: this is not efficient - we've already computed this patch on the other side but it's difficult to route this through. We need to do this to preserve the insertion point. We could just send the Changeset instead of the Document and do it all here.
                let patches = computePatches(tv.string, b: newDoc.text)
                let selected = tv.selectedRange
                let currentPos = Position(selected.location)
                let newPos = newPosition(currentPos, patches: patches)
                
                self.editor.textStorage.replaceAll(newDoc.text)
                
                // adjust the selection length so we don't select past the end
                let newSelection = adjustSelection(selected, newPosition: newPos, newString: newDoc.text)
                tv.setSelectedRange(newSelection)
            }
        }

        self.connectedDocument.onCursorUpdate = { selection in
            if let tv = XcodeUtils.sourceTextView(self.editor.controller) {
                if self.cursors[selection.id] == nil {
                    self.cursors[selection.id] = Cursor(color: selection.color, textView: tv)
                }
                self.cursors[selection.id]?.selection = selection
            }
        }
    }


    func enableDisconnectionAlert() {
        self.connectedDocument.onDisconnect = { error in
            if let window = self.editor.document.windowForSheet {
                var alert: NSAlert?
                if let error = error {
                    alert = NSAlert(error: error)
                } else {
                    alert = NSAlert()
                    alert?.messageText = "Disconnected"
                    alert?.addButtonWithTitle("Ah well.")
                    alert?.informativeText = "The connection has been dropped at the other end. Not really sure why but the upshot is there won't be any updates coming through anymore. Try reconnecting!"
                }
                alert?.beginSheetModalForWindow(window) { _ in }
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
    let length = min(selection.length, newLength - pos)
    let newSelection = NSRange(location: pos, length: length)
    return newSelection
}

