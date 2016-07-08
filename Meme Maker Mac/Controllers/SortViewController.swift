//
//  SortViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/6/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class SortViewController: NSViewController {
	
	@IBOutlet weak var defaultSortButton: NSButton!
	@IBOutlet weak var alphaSortButton: NSButton!
	@IBOutlet weak var popSortButton: NSButton!
	
	@IBOutlet weak var veView: NSVisualEffectView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		defaultSortButton.state = NSOffState
		alphaSortButton.state = NSOffState
		popSortButton.state = NSOffState
		
		let sortKey = SettingsManager.getInteger(kSettingsLastSortKey)
		if sortKey > 0 {
			if (sortKey == 1) {
				defaultSortButton.state = NSOnState
			} else if (sortKey == 2) {
				alphaSortButton.state = NSOnState
			} else if (sortKey == 3) {
				popSortButton.state = NSOnState
			}
		} else {
			defaultSortButton.state = NSOnState
			SettingsManager.setInteger(1, key: kSettingsLastSortKey)
		}
		
		updateViews()
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.updateViews()
		}
		
    }
	
	func updateViews() -> Void {
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		var append = ""
		if (darkMode) {
			veView.material = .Dark
			append = "W"
		} else {
			veView.material = .Light
		}
		defaultSortButton.image = NSImage(named: "sort" + append)
		alphaSortButton.image = NSImage(named: "sortAlpha" + append)
		popSortButton.image = NSImage(named: "sortRank" + append)
		
	}
	
	@IBAction func defaultSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOnState
		alphaSortButton.state = NSOffState
		popSortButton.state = NSOffState
		SettingsManager.setInteger(1, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
		self.dismissController(self)
	}
	
	@IBAction func alphaSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOffState
		alphaSortButton.state = NSOnState
		popSortButton.state = NSOffState
		SettingsManager.setInteger(2, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
		self.dismissController(self)
	}
	
	@IBAction func popSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOffState
		alphaSortButton.state = NSOffState
		popSortButton.state = NSOnState
		SettingsManager.setInteger(3, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
		self.dismissController(self)
	}
	
}
