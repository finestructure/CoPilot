//
//  MainController.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 21/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa

class MainController: NSWindowController {

    @IBOutlet weak var servicesTableView: NSTableView!
    var browser: Browser!
    var publishedService: NSNetService?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.browser = Browser(service: CoPilotService) { _ in
            self.servicesTableView.reloadData()
        }
        self.browser.onRemove = { _ in
            self.servicesTableView.reloadData()
        }
    }
}


// MARK: - Actions
extension MainController {
    
    @IBAction func publishPressed(sender: AnyObject) {
        let name = NSHost.currentHost().localizedName
        self.publishedService = publish(service: CoPilotService, name: name!)
    }
    
    @IBAction func subscribePressed(sender: AnyObject) {
    }
    
}


// MARK: - NSTableViewDataSource
extension MainController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.browser.services.count
    }
    
}


// MARK: - NSTableViewDelegate
extension MainController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCell", owner: self) as? NSTableCellView
        if row < self.browser.services.count { // guarding against race condition
            let item = self.browser.services[row] as! NSNetService
            cell?.textField?.stringValue = item.name
        }
        return cell
    }
    
}

