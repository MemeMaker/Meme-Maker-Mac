//
//  WindowController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
	
	@IBOutlet weak var gridToolBarItem: NSToolbarItem!
	
	var grid: Bool = false {
		didSet {
			SettingsManager.setBool(grid, key: kSettingsViewModeIsGrid)
			NSNotificationCenter.defaultCenter().postNotificationName(kToggleViewModeNotification, object: nil, userInfo: [kToggleViewModeKey:NSNumber.init(bool: grid)])
			if (grid) { gridToolBarItem.image = NSImage(named: "list") }
			else { gridToolBarItem.image = NSImage(named: "grid") }
		}
	}

    override func windowDidLoad() {
		
        super.windowDidLoad()
		
		grid = SettingsManager.getBool(kSettingsViewModeIsGrid)
		
    }
	
	// MARK: - Toolbar actions
	
	@IBAction func gridViewToggleAction(sender: AnyObject) {
		grid = !grid
	}
	
	@IBAction func fontToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func colorsToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func resetToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kResetPositionNotification, object: nil)
	}

}
