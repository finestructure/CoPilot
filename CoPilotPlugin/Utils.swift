//
//  Utils.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


func observe(name: String?, object: AnyObject? = nil, block: (NSNotification!) -> Void) -> NSObjectProtocol {
    let nc = NSNotificationCenter.defaultCenter()
    let queue = NSOperationQueue.mainQueue()
    return nc.addObserverForName(name, object: object, queue: queue, usingBlock: block)
}


typealias DocumentProvider = (Void -> Document)


func fileProvider(path: String) -> (Void -> String) {
    return {
        var result: NSString?
        if let error = try({ error in
            result = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
            return
        }) {
            if error.code == 260 { // does not exist
                result = ""
                let res = try({ error in
                    result?.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: error)
                })
                if res.failed {
                    let reason = "could not create file: \(res.error!.localizedDescription)"
                    NSException(name: "fileProvider", reason: reason, userInfo: nil).raise()
                }
            } else {
                let reason = "failed to load test file: \(error.localizedDescription)"
                NSException(name: "fileProvider", reason: reason, userInfo: nil).raise()
            }
        }
        return result! as String
    }
}


func documentProvider(path: String) -> DocumentProvider {
    let fp = fileProvider(path)
    return { Document(fp()) }
}


extension NSTextStorage {

    public func replaceAll(text: String) {
        let range = NSRange(location: 0, length: self.length)
        self.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: text))
    }

}


struct Editor {
    let controller: NSViewController
    let document: NSDocument
    let textStorage: NSTextStorage
}


typealias UpdateHandler = (Document -> Void)


protocol DocumentManager {
    var onUpdate: UpdateHandler? { get set }
    func update(newDocument: Document)
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

