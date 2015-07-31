//
//  UrlController.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 28/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa

class UrlController: NSWindowController {

    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var subscribeButton: NSButton!
    @IBOutlet weak var portField: NSTextField!

    var activeEditor: Editor?
    var windowForSheet: NSWindow?
    var observer: NSObjectProtocol?

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    override func awakeFromNib() {
        self.subscribeButton.enabled = false
        self.portField.stringValue = ":\(CoPilotBonjourService.port)"
        self.observer = observe(NSControlTextDidChangeNotification, object: self.hostField) { _ in
            self.subscribeButton.enabled = (self.hostField.stringValue.characters.count > 0)
        }
    }


    deinit {
        if let obj = self.observer {
            NSNotificationCenter.defaultCenter().removeObserver(obj)
        }
    }


    @IBAction func subscribePressed(sender: AnyObject) {
        if let url = NSURL(string: "ws://\(self.hostField.stringValue):\(CoPilotBonjourService.port)"),
           let editor = self.activeEditor {
            print("subscribing to \(url)")
            ConnectionManager.subscribe(url, editor: editor)
        } else {
            if let window = self.windowForSheet {
                let alert = NSAlert()
                alert.messageText = "Invalid URL"
                alert.addButtonWithTitle("Cheers!")
                alert.informativeText = "That ain't working. You need to check that URL, NSURL.init? isn't happy with it."
                alert.beginSheetModalForWindow(window) { _ in }
            }
        }

        self.window?.orderOut(self)
    }


    @IBAction func cancelPressed(sender: AnyObject) {
        self.window?.orderOut(self)
    }

}

