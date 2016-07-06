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
		
    }
	
	@IBAction func defaultSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOnState
		alphaSortButton.state = NSOffState
		popSortButton.state = NSOffState
		SettingsManager.setInteger(1, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
	}
	
	@IBAction func alphaSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOffState
		alphaSortButton.state = NSOnState
		popSortButton.state = NSOffState
		SettingsManager.setInteger(2, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
	}
	
	@IBAction func popSortAction(sender: AnyObject) {
		defaultSortButton.state = NSOffState
		alphaSortButton.state = NSOffState
		popSortButton.state = NSOnState
		SettingsManager.setInteger(3, key: kSettingsLastSortKey)
		NSNotificationCenter.defaultCenter().postNotificationName(kSortModeChangedNotification, object: nil)
	}
	
}
