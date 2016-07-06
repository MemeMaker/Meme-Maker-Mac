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
let kSettingsLastMemeIdOpened		= "kSettingsLastMemeIdOpened"
let kSettingsAutoDismiss			= "kAutoDismiss"
let kSettingsUploadMemes			= "kEnableMemeUpload"
let kSettingsResetSettingsOnLaunch	= "kResetSettingsOnLaunch"
let kSettingsViewModeIsGrid			= "kMemeListViewModeIsGrid"
let kSettingsLastSortKey			= "kLastSortOrderKey"
let kSettingsNumberOfElementsInGrid	= "kNumberOfElementsInGrid"

var globalBackColor: NSColor = NSColor.whiteColor()
var globalTintColor: NSColor = NSColor.blackColor()

class SettingsManager: NSObject {

	// MARK:- Shared Instance
	
	private static let defaults = NSUserDefaults.standardUserDefaults()
	
	// MARK:- Save and fetch stuff
	
	class func setObject(object: AnyObject, key: String) {
		defaults.setObject(object, forKey: key)
	}
	
	class func getObject(key: String) -> AnyObject? {
		return defaults.objectForKey(key)
	}
	
	class func setBool(bool: Bool, key: String) {
		defaults.setBool(bool, forKey: key)
	}
	
	class func getBool(key: String) -> Bool {
		return defaults.boolForKey(key)
	}
	
	class func setInteger(value: Int, key: String) {
		defaults.setInteger(value, forKey: key)
	}
	
	class func getInteger(key: String) -> Int {
		return defaults.integerForKey(key)
	}
	
	class func setFloat(value: Float, key: String) {
		defaults.setFloat(value, forKey: key)
	}
	
	class func getFloat(key: String) -> Float {
		return defaults.floatForKey(key)
	}
	
	class func deleteObject(key: String) {
		defaults.removeObjectForKey(key)
	}
	
	class func saveLastUpdateDate() -> Void {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = formatter.stringFromDate(NSDate())
		defaults.setObject(date, forKey: "lastUpdateDate")
	}
	
	class func getLastUpdateDate() -> NSDate {
		if (defaults.objectForKey("lastUpdateDate") != nil) {
			let dateString = "\(defaults.objectForKey("lastUpdateDate") as! String)"
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = formatter.dateFromString(dateString)
			return date!
		}
		return NSDate(timeIntervalSinceNow: (-10 * 86400))
	}
	
	class func getLastUpdateDateString() -> String {
		if (defaults.objectForKey("lastUpdateDate") != nil) {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "MMM dd, yyyy hh:mm a"
			let date = self.getLastUpdateDate()
			return formatter.stringFromDate(date)
		}
		return ""
	}
	
}
