//
//  ListCollectionViewItel.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class ListCollectionViewItel: BaseCollectionViewItem {

	override func viewDidLoad() {
		
		super.viewDidLoad()
		// Do view setup here.
		
		view.wantsLayer = true
		
		// Customize layer
		view.layer?.backgroundColor = NSColor.clearColor().CGColor
		view.layer?.borderWidth = 0.0
		view.layer?.borderColor = NSColor.lightGrayColor().CGColor
		
	}
	
	override func viewDidAppear() {
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		self.textField?.textColor = darkMode ? NSColor.init(white: 0.95, alpha: 1) : NSColor.init(white: 0.25, alpha: 1)
		
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.textField?.textColor = darkMode ? NSColor.init(white: 0.95, alpha: 1) : NSColor.init(white: 0.25, alpha: 1)
		}
	}
	
	override func setHighlight(selected: Bool) {
		view.layer?.borderWidth = selected ? 3.0 : 0.0
	}
	
}
