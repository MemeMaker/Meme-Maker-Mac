//
//  HelpViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/8/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

enum KeyPresses {
	case DKeyD
	case AKeyD
	case NoKey
}

import Cocoa

class HelpViewController: NSViewController {
	
	@IBOutlet weak var veView: NSVisualEffectView!
	
	@IBOutlet weak var quoteLabel: NSTextField!
	
	@IBOutlet weak var copyrightLabel: NSTextField!
	@IBOutlet weak var versionLabel: NSTextField!
	
	@IBOutlet var textView: NSTextView!
	@IBOutlet weak var textContainerView: NSScrollView!
	@IBOutlet weak var textContainerVEView: NSVisualEffectView!
	
	@IBOutlet weak var whiteroseButton: NSButton!
	var shouldAnimateWhiteRose: Bool = true
	
	var quotes: [String] = []
	
	var kp: KeyPresses = .NoKey

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("quotes", ofType: "json")!) {
			do {
				let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
				quotes = jsonData as! [String]
			}
			catch _ {}
		}
		
		NSEvent.addLocalMonitorForEventsMatchingMask(.FlagsChangedMask) { (theEvent) -> NSEvent? in
			self.flagsChanged(theEvent)
			return theEvent
		}
		
		NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (theEvent) -> NSEvent? in
			self.keyDown(theEvent)
			return theEvent
		}
		
		NSEvent.addLocalMonitorForEventsMatchingMask(.KeyUpMask) { (theEvent) -> NSEvent? in
			self.keyUp(theEvent)
			return theEvent
		}
		
		
		whiteroseButton.wantsLayer = true
		whiteroseButton.layer?.cornerRadius = 8
		
		updateQuoteLabel()
		
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .Dark : .Light
			self.textContainerVEView.material = darkMode ? .Dark : .Light
			if (darkMode) {
				self.quoteLabel.textColor = NSColor.whiteColor()
				self.textView.textColor = NSColor.whiteColor()
				self.copyrightLabel.textColor = NSColor.whiteColor()
				self.versionLabel.textColor = NSColor.whiteColor()
			} else {
				self.quoteLabel.textColor = NSColor.blackColor()
				self.textView.textColor = NSColor.blackColor()
				self.copyrightLabel.textColor = NSColor.blackColor()
				self.versionLabel.textColor = NSColor.blackColor()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(NSApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) in
			self.whiteroseButton.hidden = true
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidResignKeyNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) in
			self.whiteroseButton.hidden = true
		}
		
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NSNotificationCenter.defaultCenter().postNotificationName(kDarkModeChangedNotification, object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	func updateQuoteLabel() -> Void {
		self.quoteLabel.stringValue = quotes[(random() % quotes.count)]
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
			self.updateQuoteLabel()
		})

	}
	
	@IBAction func appStoreAction(sender: AnyObject) {
		let URL = NSURL(string: "https://itunes.apple.com/app/id962121383")
		NSWorkspace.sharedWorkspace().openURL(URL!)
	}
	
	@IBAction func whiteroseAction(sender: AnyObject) {
		let URL = NSURL(string: "http://darkarmy.xyz/home/")
		NSWorkspace.sharedWorkspace().openURL(URL!)
	}
	
	func updateWhiteRoseImages(index: Int) -> Void {
		if (!shouldAnimateWhiteRose) {
			return
		}
		if (index == 18) {
			whiteroseButton.image = NSImage(named: "WhiteRose")
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * Int64(USEC_PER_SEC)), dispatch_get_main_queue(), {
				self.shouldAnimateWhiteRose = false
				self.whiteroseButton.hidden = true
				SettingsManager.setBool(true, key: kSettingsDarkMode)
				NSNotificationCenter.defaultCenter().postNotificationName(kDarkModeChangedNotification, object: nil, userInfo: ["darkMode": Bool(true)])
			})
			return
		}
		let image = NSImage(named: "\(index)")
		whiteroseButton.image = image
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 80 * Int64(USEC_PER_SEC)), dispatch_get_main_queue(), {
			self.updateWhiteRoseImages(index + 1)
		})
	
	}
    
}

extension HelpViewController {
	
	override func keyDown(theEvent: NSEvent) {
		let keyCode = theEvent.keyCode
		if (keyCode == 2 && kp == .NoKey) {
			kp = .DKeyD
			return
		} else if (keyCode == 0 && kp == .DKeyD) {
			kp = .NoKey
			shouldAnimateWhiteRose = true
			whiteroseButton.hidden = false
			updateWhiteRoseImages(0)
			return
		} else {
			kp = .NoKey
		}
	}
	
	override func flagsChanged(theEvent: NSEvent) {
		let rawValue = theEvent.modifierFlags.rawValue
		if (rawValue/1000 == 524) {
			textContainerView.alphaValue = 0
			textContainerVEView.alphaValue = 0
		} else if (rawValue == 1835305) {
			whiteroseButton.hidden = false
			shouldAnimateWhiteRose = true
			updateWhiteRoseImages(0)
		} else {
			whiteroseButton.hidden = true
			textContainerView.alphaValue = 1
			textContainerVEView.alphaValue = 1
			shouldAnimateWhiteRose = false
		}
	}
	
}
