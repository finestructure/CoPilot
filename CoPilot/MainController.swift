//
//  MainController.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 21/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


class MainController: NSWindowController {

    enum SheetReturnCode: Int {
        case Cancel
        case Subscribe
        case Url
    }

    @IBOutlet weak var subscribeButton: NSButton!
    @IBOutlet weak var servicesTableView: NSTableView!

    var browser: Browser!
    var activeEditor: Editor?
    var windowForSheet: NSWindow?

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.window?.delegate = self
        self.browser = Browser(service: CoPilotBonjourService) { _ in
            self.servicesTableView.reloadData()
        }
        self.browser.onRemove = { _ in
            self.servicesTableView.reloadData()
        }
        self.servicesTableView.doubleAction = #selector(MainController.rowDoubleClicked(_:))
        self.updateUI()
    }
    
}


// MARK: - Actions
extension MainController {
    
    @IBAction func subscribePressed(sender: AnyObject) {
        let index = self.servicesTableView.selectedRow
        if index != -1 {
            let service = self.browser[index]
            self.subscribe(service)
            self.windowForSheet?.endSheet(self.window!, returnCode: SheetReturnCode.Subscribe.rawValue)
        }
    }

    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.windowForSheet?.endSheet(self.window!, returnCode: SheetReturnCode.Cancel.rawValue)
    }
    
    
    @IBAction func subscribeViaUrlClicked(sender: AnyObject) {
        self.windowForSheet?.endSheet(self.window!, returnCode: SheetReturnCode.Url.rawValue)
    }


    func rowDoubleClicked(sender: AnyObject) {
        let index = self.servicesTableView.clickedRow
        if 0 <= index && index < self.browser.count {
            let service = self.browser[index]
            self.subscribe(service)
            self.windowForSheet?.endSheet(self.window!, returnCode: SheetReturnCode.Subscribe.rawValue)
        }
    }
    
    
    func subscribe(service: NSNetService) {
        print("subscribing to \(service)")
        // FIXME: we need to make sure to warn against overwrite here
        if let editor = self.activeEditor {
            ConnectionManager.subscribe(service, editor: editor)
        }
    }
    
}
    
    
// MARK: - Helpers
extension MainController {
    
    func updateUI() {
        self.subscribeButton.enabled = (self.activeEditor != nil) && (self.servicesTableView.selectedRow != -1)
    }
    
}


// MARK: - NSTableViewDataSource
extension MainController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.browser?.count ?? 0
    }
    
}


// MARK: - NSTableViewDelegate
extension MainController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCell", owner: self) as? NSTableCellView
        if row < self.browser.count { // guarding against race condition
            let item = self.browser[row]
            cell?.textField?.stringValue = item.name
        }
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        self.subscribeButton.enabled = (self.servicesTableView.selectedRow != -1)
    }
    
}


// MARK: - NSWindowDelegate
extension MainController: NSWindowDelegate {
    
    func windowDidBecomeKey(notification: NSNotification) {
        self.updateUI()
    }

}

