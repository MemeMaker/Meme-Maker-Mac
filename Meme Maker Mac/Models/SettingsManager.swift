//
//  SettingsManager.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/5/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import AppKit

class SettingsManager: NSObject {
	
	private static let filePath = documentsPathForFileName("prefs")
	
	// MARK:- Save and fetch stuff
	
	class func setObject(object: AnyObject, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(object, forKey: key)
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func getObject(key: String) -> AnyObject? {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			return dict.objectForKey(key)
		}
		return ""
	}
	
	class func setBool(bool: Bool, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber(bool: bool), forKey: key)
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func getBool(key: String) -> Bool {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.objectForKey(key) {
				return value.boolValue
			}
		}
		return false
	}
	
	class func setInteger(value: Int, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber.init(long: value), forKey: key)
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func getInteger(key: String) -> Int {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.objectForKey(key) {
				return value.integerValue
			}
		}
		return 0
	}
	
	class func setFloat(value: Float, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber.init(float: value), forKey: key)
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func getFloat(key: String) -> Float {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.objectForKey(key) {
				return value.floatValue
			}
		}
		return 0.0
	}
	
	class func deleteObject(key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.removeObjectForKey(key)
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func saveLastUpdateDate() -> Void {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = formatter.stringFromDate(NSDate())
			dict.setObject(date, forKey: "lastUpdateDate")
			dict.writeToFile(filePath, atomically: true)
		}
	}
	
	class func getLastUpdateDate() -> NSDate {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let date = dict.objectForKey("lastUpdateDate") {
				let dateString = "\(date as! String)"
				let formatter = NSDateFormatter()
				formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				let date = formatter.dateFromString(dateString)
				return date!
			}
		}
		return NSDate(timeIntervalSinceNow: (-10 * 86400))
	}
	
	class func getLastUpdateDateString() -> String {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let _ = dict.objectForKey("lastUpdateDate") {
				let formatter = NSDateFormatter()
				formatter.dateFormat = "MMM dd, yyyy hh:mm a"
				let date = self.getLastUpdateDate()
				return formatter.stringFromDate(date)
			}
		}
		return ""
	}
	
}
