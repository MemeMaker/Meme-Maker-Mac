//
//  WindowController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

@objc protocol WindowControllerDelegate: class {
	func windowController(windowController: NSWindowController, didToggleGridView: Bool) -> Void
	func windowController(windowController: NSWindowController, didSelectFontToolbar: Bool) -> Void
	func windowController(windowController: NSWindowController, didSelectColorToolbar: Bool) -> Void
}

class WindowController: NSWindowController {
	
	weak var delegate: WindowControllerDelegate?
	
	var grid: Bool = true

    override func windowDidLoad() {
		
        super.windowDidLoad()
		
    }
	
	// MARK: - Toolbar actions
	
	@IBAction func gridViewToggleAction(sender: AnyObject) {
		grid = !grid
		if let toolbarItem = sender as? NSToolbarItem {
			if (grid) { toolbarItem.image = NSImage(named: "list") }
			else { toolbarItem.image = NSImage(named: "grid") }
		}
		delegate?.windowController(self, didToggleGridView: grid)
	}
	
	@IBAction func fontToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func colorsToolbarAction(sender: AnyObject) {
		
	}
	
	

}
