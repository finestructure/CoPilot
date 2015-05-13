//
//  CoPilotPlugin.swift
//
//  Created by Sven Schmidt on 11/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import AppKit
import Cocoa


func publishMenuTitle(editor: Editor? = nil) -> String {
    if let editor = editor {
        let title = editor.document?.displayName
        if ConnectionManager.isPublished(editor) {
            return "CoPilot Unpublish \(title)"
        } else {
            return "CoPilot Publish \(title)"
        }
    } else {
        return "CoPilot Publish"
    }
}


var sharedPlugin: CoPilotPlugin?

class CoPilotPlugin: NSObject {
    var bundle: NSBundle! = nil
    var mainController: MainController?
    var observers = [NSObjectProtocol]()
    var publishMenuItem: NSMenuItem! = nil
    var subscribeMenuItem: NSMenuItem! = nil

    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
            sharedPlugin = CoPilotPlugin(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        super.init()

        self.bundle = bundle
        self.publishMenuItem = self.menuItem(publishMenuTitle(), action:"publish", key:"p")
        self.subscribeMenuItem = self.menuItem("CoPilot Subscribe", action:"subscribe", key:"x")

        observers.append(
            observe("NSApplicationDidFinishLaunchingNotification", object: nil) { _ in
                self.addMenuItems()
            }
        )
        observers.append(
            observe("NSTextViewDidChangeSelectionNotification", object: nil) { _ in
                self.publishMenuItem.title = publishMenuTitle(editor: XcodeUtils.activeEditor)
            }
        )
        observers.append(
            observe("NSWindowWillCloseNotification", object: nil) { note in
                if let window = note.object as? NSWindow {
                    if let conn = ConnectionManager.connected({ $0.editor.window == window }) {
                        ConnectionManager.disconnect(conn.editor)
                    }
                }
            }
        )
    }

    deinit {
        for o in self.observers {
            NSNotificationCenter.defaultCenter().removeObserver(o)
        }
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        let hasEditor = { XcodeUtils.activeEditor != nil }
        let isConnected = { ConnectionManager.isConnected(XcodeUtils.activeEditor!) }
        
        switch menuItem.action {
        case Selector("publish"):
            return hasEditor()
        case Selector("subscribe"):
            return hasEditor() && !isConnected()
        default:
            return NSApplication.sharedApplication().nextResponder?.validateMenuItem(menuItem) ?? false
        }
    }

}


// MARK: - Helpers
extension CoPilotPlugin {
    
    func addMenuItems() {
        var item = NSApp.mainMenu!!.itemWithTitle("Edit")
        if item != nil {
            item!.submenu!.addItem(NSMenuItem.separatorItem())
            item!.submenu!.addItem(self.publishMenuItem)
            item!.submenu!.addItem(self.subscribeMenuItem)
        }
    }

    
    func menuItem(title: String, action: Selector, key: String) -> NSMenuItem {
        let m = NSMenuItem(title: title, action: action, keyEquivalent: key)
        m.keyEquivalentModifierMask = Int((NSEventModifierFlags.ControlKeyMask | NSEventModifierFlags.CommandKeyMask).rawValue)
        m.target = self
        return m
    }
    
}


// MARK: - Actions
extension CoPilotPlugin {
    
    func publish() {
        if let editor = XcodeUtils.activeEditor {
            if ConnectionManager.isPublished(editor) {
                ConnectionManager.disconnect(editor)
            } else {
                ConnectionManager.publish(editor)
            }
            self.publishMenuItem.title = publishMenuTitle(editor: editor)
        }
    }
    

    func subscribe() {
        if let editor = XcodeUtils.activeEditor {
            if self.mainController == nil {
                self.mainController = MainController(windowNibName: "MainController")
            }
            self.mainController!.activeEditor = editor
            let sheetWindow = self.mainController!.window!
            let doc = editor.document
            doc!.windowForSheet!.beginSheet(sheetWindow) { response in
                println("response: \(response)")
            }
        }
    }
    
}

