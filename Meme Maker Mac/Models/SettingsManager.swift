//
//  SettingsManager.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/5/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import AppKit

let kSettingsTimesLaunched			= "kTimesLaunched"
let kSettingsContinuousEditing		= "kContinuousEditing"
let kSettingsAutoDismiss			= "kAutoDismiss"
let kSettingsUploadMemes			= "kEnableMemeUpload"
let kSettingsResetSettingsOnLaunch	= "kResetSettingsOnLaunch"
let kSettingsDarkMode				= "kDarkMode"
let kSettingsViewModeIsList			= "kMemeListViewModeIsList"
let kSettingsLastSortKey			= "kLastSortOrderKey"
let kSettingsNumberOfElementsInGrid	= "kNumberOfElementsInGrid"

var globalBackColor: NSColor = NSColor.whiteColor()
var globalTintColor: NSColor = NSColor.blackColor()

func updateGlobalTheme () -> Void {
	if isDarkMode() {
		globalBackColor = NSColor.whiteColor()
		globalTintColor = NSColor.blackColor()
	}
	else {
		globalBackColor = NSColor.blackColor()
		globalTintColor = NSColor.whiteColor()
	}
}

func isDarkMode() -> Bool {
	return SettingsManager.sharedManager().getBool(kSettingsDarkMode)
}

class SettingsManager: NSObject {

	// MARK:- Shared Instance
	
	private static let sharedInstance = SettingsManager()
	
	private let defaults = NSUserDefaults.standardUserDefaults()
	
	class func sharedManager () -> SettingsManager {
		return sharedInstance
	}
	
	// MARK:- Save and fetch stuff
	
	func setObject(object: AnyObject, key: String) {
		defaults.setObject(object, forKey: key)
	}
	
	func getObject(key: String) -> AnyObject? {
		return defaults.objectForKey(key)
	}
	
	func setBool(bool: Bool, key: String) {
		defaults.setBool(bool, forKey: key)
	}
	
	func getBool(key: String) -> Bool {
		return defaults.boolForKey(key)
	}
	
	func setInteger(value: Int, key: String) {
		defaults.setInteger(value, forKey: key)
	}
	
	func getInteger(key: String) -> Int {
		return defaults.integerForKey(key)
	}
	
	func setFloat(value: Float, key: String) {
		defaults.setFloat(value, forKey: key)
	}
	
	func getFloat(key: String) -> Float {
		return defaults.floatForKey(key)
	}
	
	func deleteObject(key: String) {
		defaults.removeObjectForKey(key)
	}
	
	func saveLastUpdateDate() -> Void {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = formatter.stringFromDate(NSDate())
		defaults.setObject(date, forKey: "lastUpdateDate")
	}
	
	func getLastUpdateDate() -> NSDate {
		if (defaults.objectForKey("lastUpdateDate") != nil) {
			let dateString = "\(defaults.objectForKey("lastUpdateDate") as! String)"
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = formatter.dateFromString(dateString)
			return date!
		}
		return NSDate(timeIntervalSinceNow: (-10 * 86400))
	}
	
}
