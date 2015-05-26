//
//  ConnectedController.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 14/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa

class ConnectedController: NSWindowController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statusImageView: NSImageView!
    @IBOutlet weak var currentEditorField: NSTextField!

    var observers = [NSObjectProtocol]()
    var connections = [Connection]()
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    
    override func awakeFromNib() {
        self.update()

        let notifications = [
            "NSTextViewDidChangeSelectionNotification",
            "NSWindowWillCloseNotification",
            DocumentPublishedNotification,
            DocumentConnectedNotification,
            DocumentDisconnectedNotification,
            WebSocketDisconnectedNotification,
        ]
        for name in notifications {
            observers.append(
                observe(name, object: nil) { _ in self.update() }
            )
        }
    }
    
    
    deinit {
        for o in self.observers {
            NSNotificationCenter.defaultCenter().removeObserver(o)
        }
    }
    
}


// MARK: - Helpers
extension ConnectedController {
    
    func update() {
        if let editor = XcodeUtils.activeEditor,
           let ce = ConnectionManager.connectedEditor(editor) {
            // println("\t### active editor: \(editor.document.displayName)")
            // println("\t### doc: \(ce.document.id)")
            self.connections = ce.document.connections
        } else {
            self.connections = [Connection]()
        }
        self.updateUI()
    }
    
    func updateUI() {
        self.tableView.reloadData()
        if let editor = XcodeUtils.activeEditor {
            let connected = ConnectionManager.isConnected(editor)
            self.statusImageView.image = connected ? NSImage(named: NSImageNameStatusAvailable) : NSImage(named: NSImageNameStatusNone)
            var suffix = ""
            if ConnectionManager.isPublished(editor) {
                suffix = " (published)"
            } else if ConnectionManager.isSubscribed(editor) {
                suffix = " (subscribed)"
            }
            self.currentEditorField.stringValue = editor.document.displayName + suffix
            self.currentEditorField.textColor = NSColor.blackColor()
        } else {
            self.statusImageView.image = NSImage(named: NSImageNameStatusNone)
            self.currentEditorField.stringValue = "no active editor"
            self.currentEditorField.textColor = NSColor.grayColor()
        }
    }
    
}


// MARK: - NSTableViewDataSource
extension ConnectedController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.connections.count
    }
    
}


// MARK: - NSTableViewDelegate
extension ConnectedController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("ConnectionCell", owner: self) as? NSTableCellView

        let conn = self.connections[row]
        cell?.textField?.stringValue = conn.displayName

        return cell
    }
    
}
