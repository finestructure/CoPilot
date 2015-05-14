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
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    
    override func awakeFromNib() {
        self.updateUI()
    }
    
}


// MARK: - Helpers
extension ConnectedController {
    
    func updateUI() {
        self.tableView.reloadData()
    }
    
}


// MARK: - NSTableViewDataSource
extension ConnectedController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 5
    }
    
}


// MARK: - NSTableViewDelegate
extension ConnectedController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("ConnectionCell", owner: self) as? NSTableCellView

        cell?.textField?.stringValue = "item \(row)"

        return cell
    }
    
}
