//
//  SettingsManager.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/5/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import AppKit

open class SettingsManager: NSObject {
	
	fileprivate static let filePath = documentsPathForFileName("prefs")
	
	// MARK:- Save and fetch stuff
	
	open class func setObject(_ object: Any, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(object, forKey: key as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func getObject(_ key: String) -> Any? {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			return dict.object(forKey: key as NSString)
		}
		return "" as Any?
	}
	
	open class func setBool(_ bool: Bool, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber(value: bool as Bool), forKey: key as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func getBool(_ key: String) -> Bool {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.object(forKey: key as NSString) as? BooleanLiteralType {
				return Bool(value)
			}
		}
		return false
	}
	
	open class func setInteger(_ value: Int, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber.init(value: value as Int), forKey: key as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func getInteger(_ key: String) -> Int {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.object(forKey: key as NSString) as? IntegerLiteralType {
				return Int(value)
			}
		}
		return 0
	}
	
	open class func setFloat(_ value: Float, key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.setObject(NSNumber.init(value: value as Float), forKey: key as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func getFloat(_ key: String) -> Float {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let value = dict.object(forKey: key as NSString) as? FloatLiteralType {
				return Float(value)
			}
		}
		return 0.0
	}
	
	open class func deleteObject(_ key: String) {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			dict.removeObject(forKey: key as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func saveLastUpdateDate() -> Void {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = formatter.string(from: Date())
			dict.setObject(date, forKey: "lastUpdateDate" as NSString)
			dict.write(toFile: filePath, atomically: true)
		}
	}
	
	open class func getLastUpdateDate() -> Date {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let date = dict.object(forKey: "lastUpdateDate") {
				let dateString = "\(date as! String)"
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				let date = formatter.date(from: dateString)
				return date!
			}
		}
		return Date(timeIntervalSinceNow: (-10 * 86400))
	}
	
	open class func getLastUpdateDateString() -> String {
		if let dict = NSMutableDictionary(contentsOfFile: filePath) {
			if let _ = dict.object(forKey: "lastUpdateDate") {
				let formatter = DateFormatter()
				formatter.dateFormat = "MMM dd, yyyy hh:mm a"
				let date = self.getLastUpdateDate()
				return formatter.string(from: date)
			}
		}
		return ""
	}
	
}
