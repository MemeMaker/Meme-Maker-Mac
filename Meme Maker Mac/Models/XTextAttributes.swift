//
//  XTextAttributes.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/6/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import AppKit
import Foundation

class XTextAttributes: NSObject {
	
	var text: NSString = ""
	var uppercase: Bool = true

	var rect: CGRect = CGRect.zero
	var offset: CGPoint = CGPoint.zero
	
	var fontSize: CGFloat = 44
	var font: NSFont = NSFont(name: "Impact", size: 44)!
	
	var textColor: NSColor = NSColor.white
	var outlineColor: NSColor = NSColor.black
	
	var alignment: NSTextAlignment = .center
	var absAlignment: Int {
		set (absA) {
			switch absA {
				case 0: alignment = .left
					break;
				case 2: alignment = .right
					break;
				case 3: alignment = .justified
					break;
				default: alignment = .center
					break;
			}
		}
		get {
			switch alignment {
				case .left: return 0
				case .right: return 2
				case .justified: return 3
				default: return 1
			}
		}
	}
	
	var strokeWidth: CGFloat = 2
	
	var opacity: CGFloat = 1
	
	var shadowEnabled: Bool = true
	var shadow3D: Bool = false
	
	init(savename: String) {
		
		super.init()
		
		do {
			
			text = ""
			rect = CGRect.zero
			setDefault()
			
			if (!FileManager.default.fileExists(atPath: documentsPathForFileName(savename))) {
//				print("No such attribute file")
				return
			}
			
			if let data = try? Data.init(contentsOf: URL(fileURLWithPath: documentsPathForFileName(savename))) {
				
				let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
				
//				print("\(savename) = \(dict)")
				
				text = dict["text"] as! NSString
				uppercase = dict["uppercase"] as! Bool
				
				rect = NSRectFromString(dict["rect"] as! String)
				offset = NSPointFromString(dict["offset"] as! String)
				
				fontSize = dict["fontSize"] as! CGFloat
				let fontName = dict["fontName"] as! String
				font = NSFont(name: fontName, size: fontSize)!
				
				if let textRGB = dict["textColorRGB"] as? [String: AnyObject] {
					textColor = NSColor(red: textRGB["red"] as! CGFloat, green: textRGB["green"] as! CGFloat, blue: textRGB["blue"] as! CGFloat, alpha: 1)
				}
				
				if let outRGB = dict["outColorRGB"] as? [String: AnyObject] {
					outlineColor = NSColor(red: outRGB["red"] as! CGFloat, green: outRGB["green"] as! CGFloat, blue: outRGB["blue"] as! CGFloat, alpha: 1)
				}
				
				let align = dict["alignment"] as! Int
				switch align {
					case 0: alignment = .center
					case 1: alignment = .justified
					case 2: alignment = .left
					case 3: alignment = .right
					default: alignment = .center
				}
				
				strokeWidth = dict["strokeWidth"] as! CGFloat
				
				opacity	= dict["opacity"] as! CGFloat
				
				shadowEnabled = dict["shadowEnabled"] as! Bool
				shadow3D = dict["shadow3D"] as! Bool
				
			}
		} catch _ {
			print("attribute reading failed")
		}
		
	}
	
	func saveAttributes(_ savename: String) -> Bool {
		
		let dict = NSMutableDictionary()
		
		dict["text"] = text
		dict["uppercase"] = NSNumber(value: uppercase as Bool)
		
		dict["rect"] = NSStringFromRect(rect)
		dict["offset"] = NSStringFromPoint(offset)
		
		let fontName = font.fontName
		let fontSizeNum = NSNumber(value: Float(fontSize) as Float)
		dict["fontSize"] = fontSizeNum
		dict["fontName"] = fontName
		
		if let ntextColor = textColor.usingColorSpaceName(NSDeviceRGBColorSpace) {
			let textRGB = ["red": ntextColor.redComponent, "green": ntextColor.greenComponent, "blue": ntextColor.blueComponent]
			dict["textColorRGB"] = textRGB
		}
		
		if let noutColor = outlineColor.usingColorSpaceName(NSDeviceRGBColorSpace) {
			let outRGB = ["red": noutColor.redComponent, "green": noutColor.greenComponent, "blue": noutColor.blueComponent]
			dict["outColorRGB"] = outRGB
		}
		
		var align: Int = 0
		switch alignment {
			case .justified: align = 1
			case .left: align = 2
			case .right: align = 3
			default: align = 0
		}
		dict["alignment"] = NSNumber(value: align as Int)
		
		dict["strokeWidth"] = NSNumber(value: Float(strokeWidth) as Float)
		
		dict["opacity"] = NSNumber(value: Float(opacity) as Float)
		
		dict["shadowEnabled"] = NSNumber(value: shadowEnabled as Bool)
		dict["shadow3D"] = NSNumber(value: shadow3D as Bool)
		
//		print("SAVING : \(savename) = \(dict)")
		
		do {
			let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
			try data.write(to: URL(fileURLWithPath: documentsPathForFileName(savename)), options: .atomicWrite)
		} catch _ {
			print("attribute writing failed")
		}
		
		return true
		
	}
	
	func resetOffset() -> Void {
		offset = CGPoint.zero
		fontSize = 44
	}
	
	func setDefault() -> Void {
		uppercase = true
		offset = CGPoint.zero
		fontSize = 44
		font = NSFont(name: "Impact", size: fontSize)!
		textColor = NSColor.white
		outlineColor = NSColor.black
		alignment = .center
		strokeWidth = 2
		opacity = 1
	}
	
	func getTextAttributes() -> [String: AnyObject] {
		
		var attr: [String: AnyObject] = [:]
		
		font = NSFont(name: font.fontName, size: fontSize)!
		attr[NSFontAttributeName] = font
		
		attr[NSForegroundColorAttributeName] = textColor.withAlphaComponent(opacity)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.maximumLineHeight = fontSize
		paragraphStyle.alignment = alignment
		
		attr[NSParagraphStyleAttributeName] = paragraphStyle
		
		attr[NSStrokeWidthAttributeName] = NSNumber(value: Float(-strokeWidth) as Float)
		
		attr[NSStrokeColorAttributeName] = outlineColor
		
		if (shadowEnabled) {
			let shadow = NSShadow()
			shadow.shadowColor = outlineColor
			if (shadow3D) {
				shadow.shadowOffset = CGSize(width: 0, height: -1)
				shadow.shadowBlurRadius = 1.5
			} else {
				shadow.shadowOffset = CGSize(width: 0.1, height: 0.1)
				shadow.shadowBlurRadius = 0.8
			}
			attr[NSShadowAttributeName] = shadow
		}
		
		return attr
		
	}
	
	class func clearTopAndBottomTexts() -> Void {
		// We don't want text to retain when selecting new meme?
		let topTextAttr = XTextAttributes(savename: "topAttr")
		topTextAttr.text = ""
		topTextAttr.setDefault()
		if topTextAttr.saveAttributes("topAttr") {
			print("Save success")
		}
		let bottomTextAttr = XTextAttributes(savename: "bottomAttr")
		bottomTextAttr.text = ""
		bottomTextAttr.setDefault()
		if bottomTextAttr.saveAttributes("bottomAttr") {
			print("Save success")
		}
	}
	
}
