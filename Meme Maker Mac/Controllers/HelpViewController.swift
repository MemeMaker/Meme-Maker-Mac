//
//  HelpViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/8/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class HelpViewController: NSViewController {
	
	@IBOutlet weak var veView: NSVisualEffectView!
	
	@IBOutlet weak var quoteLabel: NSTextField!
	
	@IBOutlet var textView: NSTextView!
	@IBOutlet weak var textContainerView: NSScrollView!
	@IBOutlet weak var textContainerVEView: NSVisualEffectView!
	
	
	var quotes: [String] = []

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
		
		updateQuoteLabel()
		
		NSNotificationCenter.defaultCenter().addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .Dark : .Light
			self.textContainerVEView.material = darkMode ? .Dark : .Light
			if (darkMode) {
				self.quoteLabel.textColor = NSColor.whiteColor()
				self.textView.textColor = NSColor.whiteColor()
			} else {
				self.quoteLabel.textColor = NSColor.blackColor()
				self.textView.textColor = NSColor.blackColor()
			}
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
    
}

extension HelpViewController {
	
	override func flagsChanged(theEvent: NSEvent) {
		let rawValue = theEvent.modifierFlags.rawValue
		if (rawValue/1000 == 524) {
			textContainerView.alphaValue = 0
			textContainerVEView.alphaValue = 0
		} else {
			textContainerView.alphaValue = 1
			textContainerVEView.alphaValue = 1
		}
	}
	
}
