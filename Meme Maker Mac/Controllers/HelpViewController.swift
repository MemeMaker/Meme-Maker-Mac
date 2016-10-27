//
//  HelpViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/8/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

enum KeyPresses {
	case dKeyD
	case aKeyD
	case noKey
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
	
	var kp: KeyPresses = .noKey

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		if let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "quotes", ofType: "json")!)) {
			do {
				let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				quotes = jsonData as! [String]
			}
			catch _ {}
		}
		
		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (theEvent) -> NSEvent? in
			self.flagsChanged(with: theEvent)
			return theEvent
		}
		
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (theEvent) -> NSEvent? in
			self.keyDown(with: theEvent)
			return theEvent
		}
		
		NSEvent.addLocalMonitorForEvents(matching: .keyUp) { (theEvent) -> NSEvent? in
			self.keyUp(with: theEvent)
			return theEvent
		}
		
		
		whiteroseButton.wantsLayer = true
		whiteroseButton.layer?.cornerRadius = 8
		
		updateQuoteLabel()
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDarkModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .dark : .light
			self.textContainerVEView.material = darkMode ? .dark : .light
			if (darkMode) {
				self.quoteLabel.textColor = NSColor.white
				self.textView.textColor = NSColor.white
				self.copyrightLabel.textColor = NSColor.white
				self.versionLabel.textColor = NSColor.white
			} else {
				self.quoteLabel.textColor = NSColor.black
				self.textView.textColor = NSColor.black
				self.copyrightLabel.textColor = NSColor.black
				self.versionLabel.textColor = NSColor.black
			}
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSApplicationWillResignActive, object: nil, queue: OperationQueue.main) { (note) in
			self.whiteroseButton.isHidden = true
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowDidResignKey, object: nil, queue: OperationQueue.main) { (note) in
			self.whiteroseButton.isHidden = true
		}
		
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	func updateQuoteLabel() -> Void {
		self.quoteLabel.stringValue = quotes[Int(arc4random_uniform(UInt32(quotes.count)))]
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(15 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
			self.updateQuoteLabel()
		})

	}
	
	@IBAction func appStoreAction(_ sender: AnyObject) {
		let URL = Foundation.URL(string: "https://itunes.apple.com/app/id962121383")
		NSWorkspace.shared().open(URL!)
	}
	
	@IBAction func whiteroseAction(_ sender: AnyObject) {
		let URL = Foundation.URL(string: "http://darkarmy.xyz/home/")
		NSWorkspace.shared().open(URL!)
	}
	
	func updateWhiteRoseImages(_ index: Int) -> Void {
		if (!shouldAnimateWhiteRose) {
			return
		}
		if (index == 18) {
			whiteroseButton.image = NSImage(named: "WhiteRose")
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(500 * Int64(USEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
				self.shouldAnimateWhiteRose = false
				self.whiteroseButton.isHidden = true
				SettingsManager.setBool(true, key: kSettingsDarkMode)
				NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(true)])
			})
			return
		}
		let image = NSImage(named: "\(index)")
		whiteroseButton.image = image
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(80 * Int64(USEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
			self.updateWhiteRoseImages(index + 1)
		})
	
	}
    
}

extension HelpViewController {
	
	override func keyDown(with theEvent: NSEvent) {
		let keyCode = theEvent.keyCode
		if (keyCode == 2 && kp == .noKey) {
			kp = .dKeyD
			return
		} else if (keyCode == 0 && kp == .dKeyD) {
			kp = .noKey
			shouldAnimateWhiteRose = true
			whiteroseButton.isHidden = false
			updateWhiteRoseImages(0)
			return
		} else {
			kp = .noKey
		}
	}
	
	override func flagsChanged(with theEvent: NSEvent) {
		let rawValue = theEvent.modifierFlags.rawValue
		if (rawValue/1000 == 524) {
			textContainerView.alphaValue = 0
			textContainerVEView.alphaValue = 0
		} else if (rawValue == 1835305) {
			whiteroseButton.isHidden = false
			shouldAnimateWhiteRose = true
			updateWhiteRoseImages(0)
		} else {
			whiteroseButton.isHidden = true
			textContainerView.alphaValue = 1
			textContainerVEView.alphaValue = 1
			shouldAnimateWhiteRose = false
		}
	}
	
}
