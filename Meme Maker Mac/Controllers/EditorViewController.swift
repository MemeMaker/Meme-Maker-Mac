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
	
	@IBOutlet weak var imageView: NSImageView!
	
	@IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var topAlignmentSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var bottomAlignmentSegmentedControl: NSSegmentedControl!
	
	var pinchGestureRecognizer: NSMagnificationGestureRecognizer?
	var panGestureRecognizer: NSPanGestureRecognizer?
	var doubleClickGestureRecognizer: NSClickGestureRecognizer?
	
	var movingTop: Bool = true;
	var shouldDragText: Bool = false;
	
	var topTextAttr: XTextAttributes =  XTextAttributes(savename: "topAttr")
	var bottomTextAttr: XTextAttributes = XTextAttributes(savename: "bottomAttr")
	
	var meme: XMeme!  {
		didSet {
			if let image = NSImage.init(contentsOfFile: imagesPathForFileName("\(meme.memeID)")) {
				imageView?.image = image
				baseImage = image
			}
			cookImage()
		}
	}
	
	var baseImage: NSImage?
	
	// MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		setupGestureRecognizers()
		
		handleNotifications()
		
		topField.stringValue = topTextAttr.text as String
		bottomField.stringValue = bottomTextAttr.text as String
		
		topAlignmentSegmentedControl.selectedSegment = topTextAttr.absAlignment
		bottomAlignmentSegmentedControl.selectedSegment = bottomTextAttr.absAlignment
		
		NSFontManager.sharedFontManager().target = self
		NSFontManager.sharedFontManager().action = #selector(EditorViewController.changeFont(_:))
		NSFontPanel.sharedFontPanel().setPanelFont(topTextAttr.font, isMultiple: false)
		
		NSColorPanel.sharedColorPanel().setTarget(self)
		NSColorPanel.sharedColorPanel().setAction(#selector(EditorViewController.changeColor(_:)))
		NSColorPanel.sharedColorPanel().color = topTextAttr.textColor
		NSColorPanel.sharedColorPanel().runToolbarCustomizationPalette(self)
		
		NSEvent.addLocalMonitorForEventsMatchingMask(.FlagsChangedMask) { (theEvent) -> NSEvent? in
			self.flagsChanged(theEvent)
			return theEvent
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
			self.cookImage()
		}
		
		center.addObserverForName(kFontBiggerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.fontSize = min(self.topTextAttr.fontSize + 4, 120)
			self.bottomTextAttr.fontSize = min(self.bottomTextAttr.fontSize + 4, 120)
			self.cookImage()
		}
		
		center.addObserverForName(kFontSmallerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.topTextAttr.fontSize = max(self.topTextAttr.fontSize - 4, 20)
			self.bottomTextAttr.fontSize = max(self.bottomTextAttr.fontSize - 4, 20)
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
				if (topbottom == 1) {
					if let topText = self.meme.topText {
						self.topTextAttr.text = topText
						self.topField.stringValue = topText
					}
				} else if (topbottom == 9) {
					if let bottomText = self.meme.bottomText {
						self.bottomTextAttr.text = bottomText
						self.bottomField.stringValue = bottomText
					}
				}
				self.cookImage()
			}
		}
		
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
	}
	
	@IBAction func topSizeChange(sender: NSSegmentedControl) {
		topTextAttr.fontSize += (sender.selectedSegment == 0) ? -2 : 2;
		topTextAttr.fontSize = max(topTextAttr.fontSize, 12)
		topTextAttr.fontSize = min(topTextAttr.fontSize, 144)
		cookImage()
	}
	
	@IBAction func bottomAlignmentChange(sender: NSSegmentedControl) {
		let alignment = sender.selectedSegment
		bottomTextAttr.absAlignment = alignment
		cookImage()
	}
	
	@IBAction func bottomSizeChange(sender: NSSegmentedControl) {
		bottomTextAttr.fontSize += (sender.selectedSegment == 0) ? -2 : 2;
		bottomTextAttr.fontSize = max(bottomTextAttr.fontSize, 12)
		bottomTextAttr.fontSize = min(bottomTextAttr.fontSize, 144)
		cookImage()
	}
	
	override func changeFont(sender: AnyObject?) {
		if let topFont = sender?.convertFont(topTextAttr.font) {
			topTextAttr.font = topFont
		}
		if let bottomFont = sender?.convertFont(bottomTextAttr.font) {
			bottomTextAttr.font = bottomFont
		}
		cookImage()
	}
	
	override func changeColor(sender: AnyObject?) {
		topTextAttr.textColor = (sender?.color)!
		bottomTextAttr.textColor = (sender?.color)!
		cookImage()
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
				topTextAttr.fontSize = min(topTextAttr.fontSize + fontScale, 120)
			} else {
				topTextAttr.fontSize = max(topTextAttr.fontSize + fontScale, 20)
			}
		} else {
			if (fontScale > 0) {
				bottomTextAttr.fontSize = min(bottomTextAttr.fontSize + fontScale, 120)
			} else {
				bottomTextAttr.fontSize = max(bottomTextAttr.fontSize + fontScale, 20)
			}
		}
		cookImage()
	}
	
	func handlePan(recognizer: NSPanGestureRecognizer) -> Void {
		let translation = recognizer.translationInView(self.imageView)
		if (movingTop) {
			topTextAttr.offset = CGPointMake(topTextAttr.offset.x + recognizer.velocityInView(self.imageView).x/60,
			                                 topTextAttr.offset.y + recognizer.velocityInView(self.imageView).y/60);
		}
		else {
			bottomTextAttr.offset = CGPointMake(bottomTextAttr.offset.x + recognizer.velocityInView(self.imageView).x/60,
			                                    bottomTextAttr.offset.y + recognizer.velocityInView(self.imageView).y/60);
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