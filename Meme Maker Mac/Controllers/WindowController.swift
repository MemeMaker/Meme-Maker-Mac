//
//  WindowController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

let kToggleViewModeNotification: String = "kToggleViewModeNotification"
let kToggleViewModeKey: String = "kToggleViewModeKey"

import Cocoa

class WindowController: NSWindowController {
	
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
		NSNotificationCenter.defaultCenter().postNotificationName(kToggleViewModeNotification, object: nil, userInfo: [kToggleViewModeKey:NSNumber.init(bool: grid)])
	}
	
	@IBAction func fontToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func colorsToolbarAction(sender: AnyObject) {
		
	}
	
	

}
