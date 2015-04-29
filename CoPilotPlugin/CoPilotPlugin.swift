//
//  CoPilotPlugin.swift
//
//  Created by Sven Schmidt on 11/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import AppKit
import Cocoa


var currentWindow: NSWindow? {
get {
    return NSApplication.sharedApplication().keyWindow
}
}


var currentWorkspaceWindowController: NSObject? {
get {
    let type: AnyClass! = NSClassFromString("IDEWorkspaceWindowController")
    if currentWindow?.windowController()?.isKindOfClass(type) != nil {
        return currentWindow?.windowController() as? NSObject
    } else {
        return nil
    }
}
}


//var currentEditorArea: AnyObject? {
//get {
//    return currentWorkspaceWindowController?.editorArea
//}
//}
//
//
//var currentEditorContext: AnyObject? {
//get {
//    return currentEditorArea?.lastActiveEditorContext
//}
//}
//
//
//var currentEditor: AnyObject? {
//get {
//    return currentEditorContext?.editor
//}
//}


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
        createMenuItems()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
}


// MARK: - Actions
extension CoPilotPlugin {

    func publish() {
        
    }
    
    func browse() {
        if self.mainController == nil {
            self.mainController = MainController(windowNibName: "MainController")
        }
        self.mainController?.showWindow(self)
    }
    
}

