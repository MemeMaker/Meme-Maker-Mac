//
//  WindowController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
	
	@IBOutlet weak var toolbar: NSToolbar!
	
	@IBOutlet weak var gridToolBarItem: NSToolbarItem!
	@IBOutlet weak var sortToolbarItem: NSToolbarItem!
	@IBOutlet weak var resetToolbarItem: NSToolbarItem!
	@IBOutlet weak var attributesToolbarItem: NSToolbarItem!
	
	@IBOutlet weak var searchField: NSSearchField!
	
	var grid: Bool = false {
		didSet {
			SettingsManager.setBool(grid, key: kSettingsViewModeIsGrid)
			NSNotificationCenter.defaultCenter().postNotificationName(kToggleViewModeNotification, object: nil, userInfo: [kToggleViewModeKey:NSNumber.init(bool: grid)])
			self.updateButtonImages()
		}
	}
	
	var isFullScreen: Bool = false {
		didSet {
			self.updateButtonImages()
		}
	}

    override func windowDidLoad() {
		
        super.windowDidLoad()
		
		grid = SettingsManager.getBool(kSettingsViewModeIsGrid)
		updateButtonImages()
		
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.updateButtonImages()
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(NSWindowWillEnterFullScreenNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.isFullScreen = true
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(NSWindowWillExitFullScreenNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.isFullScreen = false
		}
		
    }
	
	func updateButtonImages() -> Void {
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		var suffix = ""
		if (darkMode && !isFullScreen) {
			suffix = "W"
			toolbar.showsBaselineSeparator = false
		} else {
			toolbar.showsBaselineSeparator = true
		}
		if (grid) { gridToolBarItem.image = NSImage(named: "list" + suffix) }
		else { gridToolBarItem.image = NSImage(named: "grid" + suffix) }
		sortToolbarItem.image = NSImage(named: "sort" + suffix)
		resetToolbarItem.image = NSImage(named: "reset" + suffix)
		attributesToolbarItem.image = NSImage(named: "attrs" + suffix)
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
	
	@IBAction func undoToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kUndoNotification, object: nil)
	}
	
	@IBAction func redoToolbarAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kRedoNotification, object: nil)
	}
	

}

extension WindowController {
	
	override func controlTextDidChange(obj: NSNotification) {
		let text = self.searchField.stringValue
		SettingsManager.setObject(text, key: kSettingsLastSearchKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSearchBarTextChangedNotification, object: nil, userInfo: [kSettingsLastSearchKey: text])
	}
	
}
