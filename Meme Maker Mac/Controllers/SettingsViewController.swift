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
	
	@IBOutlet weak var updationSpinner: NSProgressIndicator!
	
	@IBOutlet weak var veView: NSVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		resetSettingsButton.state = SettingsManager.getBool(kSettingsResetSettingsOnLaunch) ? NSOnState : NSOffState
		
		darkModeButton.state = SettingsManager.getBool(kSettingsDarkMode) ? NSOnState : NSOffState
		
		lastUpdatedLabel.stringValue = "Last updated: " + SettingsManager.getLastUpdateDateString()
		
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .UltraDark : .Light
		}
		
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NSNotificationCenter.defaultCenter().postNotificationName(kDarkModeChangedNotification, object: nil, userInfo: ["darkMode": NSNumber.init(bool: darkMode)])
	}
	
}

extension SettingsViewController {
	
	@IBAction func memeMakerAction(sender: AnyObject) {
		
	}

	@IBAction func resetSettingsAction(sender: AnyObject) {
		SettingsManager.setBool(sender.state == NSOnState, key: kSettingsResetSettingsOnLaunch)
	}
	
	@IBAction func darkModeAction(sender: AnyObject) {
		let darkMode = sender.state == NSOnState
		veView.material = darkMode ? .UltraDark : .Light;
		SettingsManager.setBool(darkMode, key: kSettingsDarkMode)
		NSNotificationCenter.defaultCenter().postNotificationName(kDarkModeChangedNotification, object: nil, userInfo: ["darkMode": NSNumber.init(bool: darkMode)])
		
		
	}
	
	@IBAction func updateMemesAction(sender: AnyObject) {
		let fetcher = MemeFetcher()
		fetcher.fetchMemes()
		updationSpinner.hidden = false
		updationSpinner.startAnimation(self)
		NSNotificationCenter.defaultCenter().addObserverForName(kFetchCompleteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.updationSpinner.stopAnimation(self)
			self.updationSpinner.hidden = true
			self.lastUpdatedLabel.stringValue = "Last updated: " + SettingsManager.getLastUpdateDateString()
		}
	}
	
	@IBAction func reportBugAction(sender: AnyObject) {
		let shareItems = [getSystemDetails()]
		let service = NSSharingService(named: NSSharingServiceNameComposeEmail)
		service?.delegate = self
		service?.recipients = ["samaritan@darmarmy.xyz"]
		service?.subject = "Meme maker bug report"
		service?.performWithItems(shareItems)
	}
	
	@IBAction func feedbackAction(sender: AnyObject) {
		let shareItems = [getSystemDetails()]
		let service = NSSharingService(named: NSSharingServiceNameComposeEmail)
		service?.delegate = self
		service?.recipients = ["samaritan@darmarmy.xyz"]
		service?.subject = "Meme maker feedback/suggestion"
		service?.performWithItems(shareItems)
	}
	
	func getSystemDetails() -> String {
		if let dict = NSDictionary(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist") {
			let details = "\n\n\nSystem version = \(dict["ProductName"]!) \(dict["ProductVersion"]!)\n"
			return details
		}
		return ""
	}
    
}

extension SettingsViewController: NSSharingServiceDelegate {
	
	func sharingService(sharingService: NSSharingService, didShareItems items: [AnyObject]) {
		print("share success")
	}
	
	func sharingService(sharingService: NSSharingService, didFailToShareItems items: [AnyObject], error: NSError) {
		print("share failure")
	}
	
}

