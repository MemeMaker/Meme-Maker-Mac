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
	
	@IBOutlet weak var veView: NSVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		updateViews()
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDarkModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .dark : .light
		}
		
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(darkMode)])
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
		shadow3dbutton.isHidden = !shadowEnabled
		
		let shadow3d = topTextAttr.shadow3D
		shadow3dbutton.state = shadow3d ? NSOnState : NSOffState
		
	}
	
	func updateAttributes() -> Void {
		let userInfo:[String: AnyObject] = [kTopAttrName: topTextAttr, kBottomAttrName: bottomTextAttr]
		NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateAttributesNotification), object: nil, userInfo: userInfo)
	}
	
}

extension AttributeEditorViewController {

	@IBAction func fontscaleSliderAction(_ sender: AnyObject) {
		let result = CGFloat((sender.intValue + 1) * 20)
		topTextAttr.fontSize = result
		bottomTextAttr.fontSize = result
		updateAttributes()
	}
	
	@IBAction func outlinethicknessSliderAction(_ sender: AnyObject) {
		let result = CGFloat(sender.intValue)
		topTextAttr.strokeWidth = result
		bottomTextAttr.strokeWidth = result
		updateAttributes()
	}
	
	@IBAction func opacitySliderAction(_ sender: AnyObject) {
		let result = CGFloat(sender.doubleValue)
		topTextAttr.opacity = result
		bottomTextAttr.opacity = result
		updateAttributes()
	}
	
	@IBAction func shadowEnabledAction(_ sender: AnyObject) {
		let result = sender.state == NSOnState
		shadow3dbutton.isHidden = !result
		topTextAttr.shadowEnabled = result
		bottomTextAttr.shadowEnabled = result
		updateAttributes()
	}
	
	@IBAction func shadow3dAction(_ sender: AnyObject) {
		let result = sender.state == NSOnState
		topTextAttr.shadow3D = result
		bottomTextAttr.shadow3D = result
		updateAttributes()
	}
	
	@IBAction func textColorAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kTextColorPanelNotification), object: nil)
	}
	
	@IBAction func outlineColorAction(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kOutlineColorPanelNotification), object: nil)
	}
	
	@IBAction func textFontAction(_ sender: AnyObject) {
		let topTextAttr: XTextAttributes =  XTextAttributes(savename: kTopAttrName)
		NSFontPanel.shared().setPanelFont(topTextAttr.font, isMultiple: false)
		NSFontPanel.shared().orderFront(sender)
	}
    
}
