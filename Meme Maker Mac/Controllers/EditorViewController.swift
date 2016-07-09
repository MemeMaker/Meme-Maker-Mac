//
//  EditorViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 6/28/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {
	
	@IBOutlet weak var topField: NSTextField!
	@IBOutlet weak var bottomField: NSTextField!
	
	@IBOutlet weak var imageView: DragDropImageView!
	
	@IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var topAlignmentSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var bottomAlignmentSegmentedControl: NSSegmentedControl!
	
	var pinchGestureRecognizer: NSMagnificationGestureRecognizer?
	var panGestureRecognizer: NSPanGestureRecognizer?
	var doubleClickGestureRecognizer: NSClickGestureRecognizer?
	
	var movingTop: Bool = true
	var shouldDragText: Bool = false
	
	var textColorChange: Bool = true
	
	var topTextAttr: XTextAttributes =  XTextAttributes(savename: "topAttr")
	var bottomTextAttr: XTextAttributes = XTextAttributes(savename: "bottomAttr")
	
//	let xUndoManager: XUndoManager = XUndoManager.sharedManager()
//	var shouldAppend: Bool = true
	
	var meme: XMeme?  {
		didSet {
			guard let meme = self.meme else { return }
			if let image = NSImage.init(contentsOfFile: imagesPathForFileName("\(meme.memeID)")) {
				imageView?.image = image
				imageView?.memeName = meme.name
				baseImage = image
				saveLastImage(image)
			}
			cookImage()
		}
	}
	
	var baseImage: NSImage? {
		didSet {
			if let width = self.baseImage?.size.width {
				ratio = width/640
			}
		}
	}
	
	var ratio: CGFloat = 1.0
	
	// MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		setupGestureRecognizers()
		
		handleNotifications()
		
		imageView.delegate = self
		
		topField.stringValue = topTextAttr.text as String
		bottomField.stringValue = bottomTextAttr.text as String
		
		topAlignmentSegmentedControl.selectedSegment = topTextAttr.absAlignment
		bottomAlignmentSegmentedControl.selectedSegment = bottomTextAttr.absAlignment
		
		NSFontManager.sharedFontManager().target = self
		NSFontManager.sharedFontManager().action = #selector(EditorViewController.changeFont(_:))
		NSFontPanel.sharedFontPanel().setPanelFont(topTextAttr.font, isMultiple: false)
		NSFontPanel.sharedFontPanel().title = "Font"
		
		NSEvent.addLocalMonitorForEventsMatchingMask(.FlagsChangedMask) { (theEvent) -> NSEvent? in
			self.flagsChanged(theEvent)
			return theEvent
		}
		
		if let image = getLastImage() {
			baseImage = image
			imageView?.image = image
			imageView.memeName = ""
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200	* Int64(USEC_PER_SEC)), dispatch_get_main_queue(), {
				self.cookImage()
			})
		} else {
			baseImage = NSImage(named: "startup")
			imageView.image = baseImage
		}
		
    }
	
	func setupGestureRecognizers() -> Void {
		
		pinchGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(EditorViewController.handlePinch(_:)))
		self.imageView.addGestureRecognizer(pinchGestureRecognizer!)
		
		panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(EditorViewController.handlePan(_:)))
		
		panGestureRecognizer?.delegate = self
		self.imageView.addGestureRecognizer(panGestureRecognizer!)
		
		doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(EditorViewController.handleDoubleClick(_:)))
		doubleClickGestureRecognizer?.numberOfClicksRequired = 2
		self.imageView.addGestureRecognizer(doubleClickGestureRecognizer!)
		
	}
	
	func handleNotifications() -> Void {
		
		let center = NSNotificationCenter.defaultCenter()
		
		center.addObserverForName(kResetPositionNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.resetOffset()
			self.bottomTextAttr.resetOffset()
			self.cookImage()
		}
		
		center.addObserverForName(kResetAllNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.setDefault()
			self.bottomTextAttr.setDefault()
			NSColorPanel.sharedColorPanel().color = self.topTextAttr.textColor
			NSFontPanel.sharedFontPanel().setPanelFont(self.topTextAttr.font, isMultiple: false)
			self.cookImage()
		}
		
		center.addObserverForName(kFontBiggerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.fontSize = min(self.topTextAttr.fontSize + 4 * self.ratio, 120 * self.ratio)
			self.bottomTextAttr.fontSize = min(self.bottomTextAttr.fontSize + 4 * self.ratio, 120 * self.ratio)
			self.cookImage()
		}
		
		center.addObserverForName(kFontSmallerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.fontSize = max(self.topTextAttr.fontSize - 4 * self.ratio, 20 * self.ratio)
			self.bottomTextAttr.fontSize = max(self.bottomTextAttr.fontSize - 4 * self.ratio, 20 * self.ratio)
			self.cookImage()
		}
		
		center.addObserverForName(kAlignTextNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			guard let userInfo = notification.userInfo else { return }
			if let alignment = userInfo["alignment"]?.integerValue {
				self.topAlignmentSegmentedControl.selectedSegment = alignment
				self.bottomAlignmentSegmentedControl.selectedSegment = alignment
				self.topTextAttr.absAlignment = alignment
				self.bottomTextAttr.absAlignment = alignment
				self.cookImage()
			}
		}
		
		center.addObserverForName(kFillDefaultTextNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			guard let userInfo = notification.userInfo else { return }
			if let topbottom = userInfo["topbottom"]?.integerValue {
				guard let meme = self.meme else { return }
				if (topbottom == 1) {
					if let topText = meme.topText {
						self.topTextAttr.text = topText
						self.topField.stringValue = topText
					}
				} else if (topbottom == 9) {
					if let bottomText = meme.bottomText {
						self.bottomTextAttr.text = bottomText
						self.bottomField.stringValue = bottomText
					}
				}
				self.cookImage()
			}
		}
		
		center.addObserverForName(kTextColorPanelNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let panel = NSColorPanel.sharedColorPanel()
			panel.setTarget(self)
			self.textColorChange = true
			panel.setAction(#selector(EditorViewController.changeColor(_:)))
			panel.color = self.topTextAttr.textColor
			panel.runToolbarCustomizationPalette(self)
			panel.title = "Text Color"
			panel.makeKeyAndOrderFront(self)
		}
		
		center.addObserverForName(kOutlineColorPanelNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let panel = NSColorPanel.sharedColorPanel()
			panel.setTarget(self)
			self.textColorChange = false
			panel.setAction(#selector(EditorViewController.changeColor(_:)))
			panel.color = self.topTextAttr.outlineColor
			panel.runToolbarCustomizationPalette(self)
			panel.title = "Outline Color"
			panel.makeKeyAndOrderFront(self)
		}
		
		center.addObserverForName(kUpdateAttributesNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			guard let userInfo = notification.userInfo else { return }
			if let topAttr = userInfo[kTopAttrName] as? XTextAttributes {
				self.topTextAttr = topAttr
			}
			if let bottomAttr = userInfo[kBottomAttrName] as? XTextAttributes {
				self.bottomTextAttr = bottomAttr
			}
			self.cookImage()
		}
		
		center.addObserverForName(NSWindowDidResizeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let viewSize = self.view.bounds
			self.imageViewWidthConstraint.constant = viewSize.width - 16
			self.imageViewHeightConstraint.constant = viewSize.height - 96
			self.view.needsLayout = true
		}
		
		center.addObserverForName(kShareNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			if let image = self.imageView.image {
				let shareItems = [image, "Check out this meme I made."]
				let sharingServicePicker = NSSharingServicePicker(items: shareItems)
				sharingServicePicker.delegate = self
				sharingServicePicker.showRelativeToRect(NSZeroRect, ofView: self.view, preferredEdge: .MaxX)
			}
		}
		
		/*
		center.addObserverForName(kUndoNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let (topA, bottomA) = self.xUndoManager.undo()
			if let topAttr = topA {
				self.topTextAttr = topAttr
			}
			if let bottomAttr = bottomA {
				self.bottomTextAttr = bottomAttr
			}
			self.cookImage()
		}
		
		center.addObserverForName(kRedoNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let (topA, bottomA) = self.xUndoManager.redo()
			if let topAttr = topA {
				self.topTextAttr = topAttr
			}
			if let bottomAttr = bottomA {
				self.bottomTextAttr = bottomAttr
			}
			self.cookImage()
		}
		*/
		
	}
    
}

extension EditorViewController: DragDropImageViewDelegate {
	
	func dragDropImageView(imageView: DragDropImageView!, didFinishDropAtFilePath filePath: String!, andImage image: NSImage!) {
		// Don't create a new meme object; just change the base image
		baseImage = image
		saveLastImage(image)
		imageView.memeName = ""
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200	* Int64(USEC_PER_SEC)), dispatch_get_main_queue(), {
			self.cookImage()
		})
	}
	
}

// MARK: - Cooking

extension EditorViewController {
	
	func cookImage() -> Void {
		if (baseImage == nil) {
			return;
		}
		let imageSize = baseImage?.size as CGSize!
		let maxHeight = imageSize.height/2 - 8	// Max height of top and bottom texts
		let stringDrawingOptions: NSStringDrawingOptions = [.UsesLineFragmentOrigin]
		
		let topText = topTextAttr.uppercase ? topTextAttr.text.uppercaseString : topTextAttr.text;
		let bottomText = bottomTextAttr.uppercase ? bottomTextAttr.text.uppercaseString : bottomTextAttr.text;
		
		topTextAttr.rect = CGRectMake(4, imageSize.height - maxHeight - 8, imageSize.width - 8, maxHeight);
		var topTextRect = topText.boundingRectWithSize(CGSizeMake(imageSize.width - 8, 1000), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
//
		// Adjust top size
		while (ceil(topTextRect.size.height) > maxHeight) {
			topTextAttr.fontSize -= 1;
			topTextRect = topText.boundingRectWithSize(CGSizeMake(imageSize.width - 8, 1000), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
		}
		
		var bottomTextRect = bottomText.boundingRectWithSize(CGSizeMake(imageSize.width - 8, 1000), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
		var expectedBottomSize = bottomTextRect.size
		bottomTextAttr.rect = CGRectMake(4, 0, imageSize.width - 8, expectedBottomSize.height)
		
		// Adjust bottom size
		while (ceil(bottomTextRect.size.height) > maxHeight) {
			bottomTextAttr.fontSize -= 2;
			bottomTextRect = bottomText.boundingRectWithSize(CGSizeMake(imageSize.width - 8, 1000), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
			expectedBottomSize = bottomTextRect.size
			bottomTextAttr.rect = CGRectMake(4, 0, imageSize.width - 8, expectedBottomSize.height)
		}
		
		let offScreenRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageSize.width), pixelsHigh: Int(imageSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bitmapFormat: NSBitmapFormat.NSAlphaFirstBitmapFormat, bytesPerRow: 0, bitsPerPixel: 0)
		
		let context = NSGraphicsContext(bitmapImageRep: offScreenRep!)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrentContext(context)
		
		baseImage?.drawInRect(NSMakeRect(0, 0, imageSize.width, imageSize.height))
		
		let topRect = CGRectMake(topTextAttr.rect.origin.x + topTextAttr.offset.x, topTextAttr.rect.origin.y + topTextAttr.offset.y, topTextAttr.rect.size.width, topTextAttr.rect.size.height)
		let bottomRect = CGRectMake(bottomTextAttr.rect.origin.x + bottomTextAttr.offset.x, bottomTextAttr.rect.origin.y + bottomTextAttr.offset.y, bottomTextAttr.rect.size.width, bottomTextAttr.rect.size.height)
		
		topTextAttr.saveAttributes("topAttr")
		bottomTextAttr.saveAttributes("bottomAttr")
		
		topText.drawInRect(NSRectFromCGRect(topRect), withAttributes: topTextAttr.getTextAttributes())
		bottomText.drawInRect(NSRectFromCGRect(bottomRect), withAttributes: bottomTextAttr.getTextAttributes())
		
		NSGraphicsContext.restoreGraphicsState()
		
		let newImage = NSImage.init(size: NSSizeFromCGSize(imageSize))
		newImage.addRepresentation(offScreenRep!)
		
		imageView.image = newImage
		
	}
	
}

// MARK: - Attribute control

extension EditorViewController {
	
	@IBAction func topAlignmentChange(sender: NSSegmentedControl) {
		let alignment = sender.selectedSegment
		topTextAttr.absAlignment = alignment
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func topSizeChange(sender: NSSegmentedControl) {
		topTextAttr.fontSize += ((sender.selectedSegment == 0) ? -2 : 2) * self.ratio;
		topTextAttr.fontSize = max(topTextAttr.fontSize, 12 * self.ratio)
		topTextAttr.fontSize = min(topTextAttr.fontSize, 144 * self.ratio)
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func bottomAlignmentChange(sender: NSSegmentedControl) {
		let alignment = sender.selectedSegment
		bottomTextAttr.absAlignment = alignment
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func bottomSizeChange(sender: NSSegmentedControl) {
		bottomTextAttr.fontSize += ((sender.selectedSegment == 0) ? -2 : 2) * self.ratio;
		bottomTextAttr.fontSize = max(bottomTextAttr.fontSize, 12 * self.ratio)
		bottomTextAttr.fontSize = min(bottomTextAttr.fontSize, 144 * self.ratio)
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func fillDefaultTextAction(sender: NSSegmentedControl) {
		let tag = sender.tag
		NSNotificationCenter.defaultCenter().postNotificationName(kFillDefaultTextNotification, object: nil, userInfo: ["topbottom": Int(tag)])
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	override func changeFont(sender: AnyObject?) {
		if let topFont = sender?.convertFont(topTextAttr.font) {
			topTextAttr.font = topFont
		}
		if let bottomFont = sender?.convertFont(bottomTextAttr.font) {
			bottomTextAttr.font = bottomFont
		}
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	override func changeColor(sender: AnyObject?) {
		if (textColorChange) {
			topTextAttr.textColor = (sender?.color)!
			bottomTextAttr.textColor = (sender?.color)!
		} else {
			topTextAttr.outlineColor = (sender?.color)!
			bottomTextAttr.outlineColor = (sender?.color)!
		}
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
}

// MARK: - Gesture and key control

extension EditorViewController: NSGestureRecognizerDelegate {
	
	func handlePinch(recognizer: NSMagnificationGestureRecognizer) -> Void {
		let fontScale = recognizer.magnification
		let point = recognizer.locationInView(self.imageView)
		let topRect = NSMakeRect(0, (self.imageView.bounds.size.height)/2, (self.imageView.bounds.size.width), (self.imageView.bounds.size.height)/2)
		if (topRect.contains(point)) {
			if (fontScale > 0) {
				topTextAttr.fontSize = min(topTextAttr.fontSize + fontScale * ratio, 120 * ratio)
			} else {
				topTextAttr.fontSize = max(topTextAttr.fontSize + fontScale * ratio, 20 * ratio)
			}
		} else {
			if (fontScale > 0) {
				bottomTextAttr.fontSize = min(bottomTextAttr.fontSize + fontScale * ratio, 120 * ratio)
			} else {
				bottomTextAttr.fontSize = max(bottomTextAttr.fontSize + fontScale * ratio, 20 * ratio)
			}
		}
		cookImage()
	}
	
	func handlePan(recognizer: NSPanGestureRecognizer) -> Void {
		let translation = recognizer.translationInView(self.imageView)
		if (movingTop) {
			topTextAttr.offset = CGPointMake(topTextAttr.offset.x + ratio * recognizer.velocityInView(self.imageView).x/50,
			                                 topTextAttr.offset.y + ratio * recognizer.velocityInView(self.imageView).y/50);
		}
		else {
			bottomTextAttr.offset = CGPointMake(bottomTextAttr.offset.x + ratio * recognizer.velocityInView(self.imageView).x/50,
			                                    bottomTextAttr.offset.y + ratio * recognizer.velocityInView(self.imageView).y/50);
		}
		recognizer.setTranslation(translation, inView: imageView)
		cookImage()
	}
	
	func handleDoubleClick(recognizer: NSClickGestureRecognizer) -> Void {
		topTextAttr.uppercase = !topTextAttr.uppercase
		bottomTextAttr.uppercase = !bottomTextAttr.uppercase
		cookImage()
	}
	
	func gestureRecognizerShouldBegin(gestureRecognizer: NSGestureRecognizer) -> Bool {
		if (!shouldDragText) { return false; }
		if (gestureRecognizer == self.panGestureRecognizer) {
			let topRect = NSMakeRect(0, (self.imageView.bounds.size.height)/2, (self.imageView.bounds.size.width), (self.imageView.bounds.size.height)/2)
			let location = gestureRecognizer.locationInView(imageView)
			movingTop = (topRect.contains(location))
		}
		return true
	}
	
	override func flagsChanged(theEvent: NSEvent) {
		let rawValue = theEvent.modifierFlags.rawValue
		shouldDragText = (rawValue/1000 == 524)
	}
	
}

extension EditorViewController: NSTextFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		topTextAttr.text = "\(topField.stringValue)"
		topTextAttr.saveAttributes("topAttr")
		bottomTextAttr.text = "\(bottomField.stringValue)"
		bottomTextAttr.saveAttributes("bottomAttr")
		cookImage()
	}
}

extension EditorViewController: NSSharingServicePickerDelegate {
	
}