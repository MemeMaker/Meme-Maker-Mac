//
//  SettingsViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/6/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
	@IBOutlet weak var resetSettingsButton: NSButton!
	
	@IBOutlet weak var darkModeButton: NSButton!
	
	@IBOutlet weak var lastUpdatedLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		resetSettingsButton.state = SettingsManager.getBool(kSettingsResetSettingsOnLaunch) ? NSOnState : NSOffState
		
//		darkModeButton.state = SettingsManager.getBool(ksettings)
		
    }
	
}

extension SettingsViewController {

	@IBAction func resetSettingsAction(sender: AnyObject) {
		SettingsManager.setBool(sender.state == NSOnState, key: kSettingsResetSettingsOnLaunch)
	}
	
	@IBAction func darkModeAction(sender: AnyObject) {
		
	}
	
	@IBAction func updateMemesAction(sender: AnyObject) {
		// Perform update...
	}
	
	@IBAction func reportBugAction(sender: AnyObject) {
		
	}
	
	@IBAction func feedbackAction(sender: AnyObject) {
		
	}
	
    
}
