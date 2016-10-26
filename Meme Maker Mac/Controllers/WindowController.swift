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
	@IBOutlet weak var shareToolbarItem: NSToolbarItem!
	@IBOutlet weak var saveToolbarItem: NSToolbarItem!
	
	@IBOutlet weak var searchField: NSSearchField!
	
	var grid: Bool = false {
		didSet {
			SettingsManager.setBool(grid, key: kSettingsViewModeIsGrid)
			NotificationCenter.default.post(name: Notification.Name(rawValue: kToggleViewModeNotification), object: nil, userInfo: [kToggleViewModeKey:NSNumber.init(value: grid as Bool)])
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
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDarkModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			self.updateButtonImages()
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowWillEnterFullScreen, object: nil, queue: OperationQueue.main) { (notification) in
			self.isFullScreen = true
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowWillExitFullScreen, object: nil, queue: OperationQueue.main) { (notification) in
			self.isFullScreen = false
		}
		
		if let text = SettingsManager.getObject(kSettingsLastSearchKey) {
			searchField.stringValue = text as! String
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
		saveToolbarItem.image = NSImage(named: "save" + suffix)
		shareToolbarItem.image = NSImage(named: "share" + suffix)
	}
	
	// MARK: - Toolbar actions
	
	@IBAction func gridViewToggleAction(_ sender: AnyObject) {
		grid = !grid
	}
	
	@IBAction func sortToolbarAction(_ sender: AnyObject) {
		
	}
	
	@IBAction func fontToolbarAction(_ sender: AnyObject) {
		
	}
	
	@IBAction func textColorToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kTextColorPanelNotification), object: nil)
	}
	
	@IBAction func outlineColorToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kOutlineColorPanelNotification), object: nil)
	}
	
	@IBAction func resetToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kResetPositionNotification), object: nil)
	}
	
	@IBAction func undoToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kUndoNotification), object: nil)
	}
	
	@IBAction func redoToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kRedoNotification), object: nil)
	}
	
	@IBAction func shareToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kShareNotification), object: nil, userInfo: ["sender": sender])
	}
	
	@IBAction func saveToolbarAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kSaveNotification), object: nil)
	}

}

extension WindowController {
	
	override func controlTextDidChange(_ obj: Notification) {
		let text = self.searchField.stringValue
		SettingsManager.setObject(text, key: kSettingsLastSearchKey)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kSearchBarTextChangedNotification), object: nil, userInfo: [kSettingsLastSearchKey: text])
	}
	
}
