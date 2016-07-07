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
	
	@IBOutlet weak var searchField: NSSearchField!
	
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
	
	@IBAction func sortToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func fontToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func textColorToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kTextColorPanelNotification, object: nil)
	}
	
	@IBAction func outlineColorToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kOutlineColorPanelNotification, object: nil)
	}
	
	@IBAction func resetToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kResetPositionNotification, object: nil)
	}

}

extension WindowController {
	
	override func controlTextDidChange(obj: NSNotification) {
		let text = self.searchField.stringValue
		SettingsManager.setObject(text, key: kSettingsLastSearchKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSearchBarTextChangedNotification, object: nil, userInfo: [kSettingsLastSearchKey: text])
	}
	
}
