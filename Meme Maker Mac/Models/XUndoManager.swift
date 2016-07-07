//
//  XUndoManager.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/7/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import AppKit
import Foundation

class XUndoManager: NSObject {
	
	private static let sharedInstance = XUndoManager()
	
	private var topAttrStack: [XTextAttributes] = []
	private var bottomAttrStack: [XTextAttributes] = []
	
	private var index: Int = -1
	
	class func sharedManager() -> XUndoManager {
		return sharedInstance
	}
	
	func append(topAttr: XTextAttributes, bottomAttr: XTextAttributes) -> Void {
		topAttrStack.append(topAttr)
		bottomAttrStack.append(bottomAttr)
		index += 1
		if (topAttrStack.count > 100) {
			topAttrStack.removeFirst()
			index = 99
		}
		if (bottomAttrStack.count > 100) {
			bottomAttrStack.removeFirst()
			index = 99
		}
	}
	
	func undo() -> (topAttr: XTextAttributes?, bottomAttr: XTextAttributes?) {
		index -= 1
		if (index < 0) {
			index = -1
			return (nil, nil)
		}
		return (topAttrStack[index], bottomAttrStack[index])
	}
	
	func redo() -> (topAttr: XTextAttributes?, bottomAttr: XTextAttributes?) {
		index += 1
		if (index > topAttrStack.count - 1) {
			index = topAttrStack.count - 1
			return (nil, nil)
		}
		return (topAttrStack[index], bottomAttrStack[index])
	}
	
	func stackTop() -> (topAttr: XTextAttributes?, bottomAttr: XTextAttributes?) {
		if (index < 0 || index >= topAttrStack.count) {
			return (nil, nil)
		}
		return (topAttrStack[index], bottomAttrStack[index])
	}

	func removeAll() -> Void {
		index = -1;
		topAttrStack.removeAll()
		bottomAttrStack.removeAll()
	}
}
