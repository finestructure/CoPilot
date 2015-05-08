//
//  CoPilotPlugin.swift
//
//  Created by Sven Schmidt on 11/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import AppKit
import Cocoa


var sharedPlugin: CoPilotPlugin?

class CoPilotPlugin: NSObject {
    var bundle: NSBundle
    var mainController: MainController?

    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
            sharedPlugin = CoPilotPlugin(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        self.createMenuItems()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case Selector("publish"):
            return self.hasDoc
        case Selector("browse"):
            return true
        default:
            return NSApplication.sharedApplication().nextResponder?.validateMenuItem(menuItem) ?? false
        }
    }

}


// MARK: - Helpers
extension CoPilotPlugin {
    
    func createMenuItems() {
        var item = NSApp.mainMenu!!.itemWithTitle("Edit")
        if item != nil {
            item!.submenu!.addItem(NSMenuItem.separatorItem())
            item!.submenu!.addItem(menuItem("CoPilot Publish", action:"publish", key:"p"))
            item!.submenu!.addItem(menuItem("CoPilot Browse", action:"browse", key:"x"))
        }
    }

    
    func menuItem(title: String, action: Selector, key: String) -> NSMenuItem {
        let m = NSMenuItem(title: title, action: action, keyEquivalent: key)
        m.keyEquivalentModifierMask = Int((NSEventModifierFlags.ControlKeyMask | NSEventModifierFlags.CommandKeyMask).rawValue)
        m.target = self
        return m
    }
    
    
    var hasDoc: Bool {
        get {
            // looks weird but return (DTXcodeUtils.currentTextStorage() != nil) causes a linker error
            if let ts = DTXcodeUtils.currentSourceCodeDocument() {
                return true
            } else {
                return false
            }
        }
    }

}


// MARK: - Actions
extension CoPilotPlugin {
    
    func publish() {
        let ts = DTXcodeUtils.currentTextStorage()
        println(ts.string)
    }

    func browse() {
        if self.mainController == nil {
            self.mainController = MainController(windowNibName: "MainController")
        }
        self.mainController?.showWindow(self)
    }
    
}

