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

    @IBOutlet weak var subscribeButton: NSButton!
    @IBOutlet weak var servicesTableView: NSTableView!

    var browser: Browser!
    var activeEditor: Editor?
    var subscribedConnection: ConnectedEditor?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.window?.delegate = self
        self.browser = Browser(service: CoPilotService) { _ in
            self.servicesTableView.reloadData()
        }
        self.browser.onRemove = { _ in
            self.servicesTableView.reloadData()
        }
        self.servicesTableView.doubleAction = Selector("rowDoubleClicked:")
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
        }
    }

    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.window?.orderOut(sender)
    }
    
    
    func rowDoubleClicked(sender: AnyObject) {
        let index = self.servicesTableView.clickedRow
        let service = self.browser[index]
        self.subscribe(service)
    }
    
    
    func subscribe(service: NSNetService) {
        println("subscribing to \(service)")
        
        // FIXME: we need to make sure to warn against overwrite here
        if let ed = self.activeEditor {
            self.subscribedConnection = connectService(service, ed)
        }

        self.window?.orderOut(self)
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


extension CGRect {
    public func withWidth(width: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: self.size.height)
        return CGRect(origin: self.origin, size: size)
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

