//
//  AttributeEditorViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/5/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class AttributeEditorViewController: NSViewController {
	
	var topTextAttr: XTextAttributes = XTextAttributes(savename: "topAttr")
	var bottomTextAttr: XTextAttributes = XTextAttributes(savename: "bottomAttr")
	
	@IBOutlet weak var fontscaleSlider: NSSlider!
	@IBOutlet weak var outlinethicknessSlider: NSSlider!
	@IBOutlet weak var opacitySlider: NSSlider!
	@IBOutlet weak var shadowEnabledButton: NSButton!
	@IBOutlet weak var shadow3dbutton: NSButton!
	

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		updateViews()
		
    }
	
	func updateViews() -> Void {
		
		let size = min(topTextAttr.fontSize, bottomTextAttr.fontSize)
		fontscaleSlider.integerValue = min(Int(size/20), 6)
		
		let strokeWidth = min(topTextAttr.strokeWidth, bottomTextAttr.strokeWidth)
		outlinethicknessSlider.integerValue = Int(strokeWidth)
		
		let opacity = topTextAttr.opacity
		opacitySlider.doubleValue = Double(opacity)
		
		let shadowEnabled = topTextAttr.shadowEnabled
		shadowEnabledButton.state = shadowEnabled ? NSOnState : NSOffState
		shadow3dbutton.hidden = !shadowEnabled
		
		let shadow3d = topTextAttr.shadow3D
		shadow3dbutton.state = shadow3d ? NSOnState : NSOffState
		
	}
	
	func updateAttributes() -> Void {
		let userInfo:[String: AnyObject] = [kTopAttrName: topTextAttr, kBottomAttrName: bottomTextAttr]
		NSNotificationCenter.defaultCenter().postNotificationName(kUpdateAttributesNotification, object: nil, userInfo: userInfo)
	}
	
}

extension AttributeEditorViewController {

	@IBAction func fontscaleSliderAction(sender: AnyObject) {
		let result = CGFloat((sender.integerValue + 1) * 20)
		topTextAttr.fontSize = result
		bottomTextAttr.fontSize = result
		updateAttributes()
	}
	
	@IBAction func outlinethicknessSliderAction(sender: AnyObject) {
		let result = CGFloat(sender.integerValue)
		topTextAttr.strokeWidth = result
		bottomTextAttr.strokeWidth = result
		updateAttributes()
	}
	
	@IBAction func opacitySliderAction(sender: AnyObject) {
		let result = CGFloat(sender.doubleValue)
		topTextAttr.opacity = result
		bottomTextAttr.opacity = result
		updateAttributes()
	}
	
	@IBAction func shadowEnabledAction(sender: AnyObject) {
		let result = sender.state == NSOnState
		shadow3dbutton.hidden = !result
		topTextAttr.shadowEnabled = result
		bottomTextAttr.shadowEnabled = result
		updateAttributes()
	}
	
	@IBAction func shadow3dAction(sender: AnyObject) {
		let result = sender.state == NSOnState
		topTextAttr.shadow3D = result
		bottomTextAttr.shadow3D = result
		updateAttributes()
	}
	
    
}
