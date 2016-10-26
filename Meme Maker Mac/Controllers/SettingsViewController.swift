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
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDarkModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			self.updateViews()
		}
		
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	func updateViews() -> Void {
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		veView.material = darkMode ? .dark : .light
		darkModeButton.state = darkMode ? NSOnState : NSOffState
		resetSettingsButton.state = SettingsManager.getBool(kSettingsResetSettingsOnLaunch) ? NSOnState : NSOffState
		lastUpdatedLabel.stringValue = "Last updated: " + SettingsManager.getLastUpdateDateString()
	}
	
}

extension SettingsViewController {
	
	@IBAction func memeMakerAction(_ sender: AnyObject) {
		
	}

	@IBAction func resetSettingsAction(_ sender: AnyObject) {
		SettingsManager.setBool(sender.state == NSOnState, key: kSettingsResetSettingsOnLaunch)
	}
	
	@IBAction func darkModeAction(_ sender: AnyObject) {
		let darkMode = sender.state == NSOnState
		veView.material = darkMode ? .dark : .light;
		SettingsManager.setBool(darkMode, key: kSettingsDarkMode)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	@IBAction func updateMemesAction(_ sender: AnyObject) {
		let fetcher = MemeFetcher()
		fetcher.fetchMemes()
		updationSpinner.isHidden = false
		updationSpinner.startAnimation(self)
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kFetchCompleteNotification), object: nil, queue: OperationQueue.main) { (notification) in
			self.updationSpinner.stopAnimation(self)
			self.updationSpinner.isHidden = true
			self.lastUpdatedLabel.stringValue = "Last updated: " + SettingsManager.getLastUpdateDateString()
		}
	}
	
	@IBAction func reportBugAction(_ sender: AnyObject) {
		let shareItems = [getSystemDetails()]
		let service = NSSharingService(named: NSSharingServiceNameComposeEmail)
		service?.delegate = self
		service?.recipients = ["samaritan@darmarmy.xyz"]
		service?.subject = "Meme maker bug report"
		service?.perform(withItems: shareItems)
	}
	
	@IBAction func feedbackAction(_ sender: AnyObject) {
		let shareItems = [getSystemDetails()]
		let service = NSSharingService(named: NSSharingServiceNameComposeEmail)
		service?.delegate = self
		service?.recipients = ["samaritan@darmarmy.xyz"]
		service?.subject = "Meme maker feedback/suggestion"
		service?.perform(withItems: shareItems)
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
	
	func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
		print("share success")
	}
	
	func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
		print("share failure")
	}
	
}

