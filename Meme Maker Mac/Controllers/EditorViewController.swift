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
		
		NSFontManager.shared().target = self
		NSFontManager.shared().action = #selector(EditorViewController.changeFont(_:))
		NSFontPanel.shared().setPanelFont(topTextAttr.font, isMultiple: false)
		NSFontPanel.shared().title = "Font"
		
		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (theEvent) -> NSEvent? in
			self.flagsChanged(with: theEvent)
			return theEvent
		}
		
		if let image = getLastImage() {
			baseImage = image
			imageView?.image = image
			imageView.memeName = ""
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(200	* Int64(USEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
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
		
		let center = NotificationCenter.default
		let queue = OperationQueue.main
		
		center.addObserver(forName: NSNotification.Name(rawValue: kResetPositionNotification), object: nil, queue: queue) { (notification) in
			self.topTextAttr.resetOffset()
			self.bottomTextAttr.resetOffset()
			self.cookImage()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kResetAllNotification), object: nil, queue: queue) { (notification) in
			self.topTextAttr.setDefault()
			self.bottomTextAttr.setDefault()
			NSColorPanel.shared().color = self.topTextAttr.textColor
			NSFontPanel.shared().setPanelFont(self.topTextAttr.font, isMultiple: false)
			self.topAlignmentSegmentedControl.selectedSegment = self.topTextAttr.absAlignment
			self.bottomAlignmentSegmentedControl.selectedSegment = self.bottomTextAttr.absAlignment
			self.cookImage()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kFontBiggerNotification), object: nil, queue: queue) { (notification) in
			self.topTextAttr.fontSize = min(self.topTextAttr.fontSize + 4 * self.ratio, 120 * self.ratio)
			self.bottomTextAttr.fontSize = min(self.bottomTextAttr.fontSize + 4 * self.ratio, 120 * self.ratio)
			self.cookImage()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kFontSmallerNotification), object: nil, queue: queue) { (notification) in
			self.topTextAttr.fontSize = max(self.topTextAttr.fontSize - 4 * self.ratio, 20 * self.ratio)
			self.bottomTextAttr.fontSize = max(self.bottomTextAttr.fontSize - 4 * self.ratio, 20 * self.ratio)
			self.cookImage()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kAlignTextNotification), object: nil, queue: queue) { (notification) in
			guard let userInfo = (notification as NSNotification).userInfo else { return }
			if let alignment = (userInfo["alignment"]? as AnyObject).intValue {
				self.topAlignmentSegmentedControl.selectedSegment = alignment
				self.bottomAlignmentSegmentedControl.selectedSegment = alignment
				self.topTextAttr.absAlignment = alignment
				self.bottomTextAttr.absAlignment = alignment
				self.cookImage()
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kFillDefaultTextNotification), object: nil, queue: queue) { (notification) in
			guard let userInfo = (notification as NSNotification).userInfo else { return }
			if let topbottom = (userInfo["topbottom"]? as AnyObject).intValue {
				guard let meme = self.meme else { return }
				if (topbottom == 1) {
					if let topText = meme.topText {
						self.topTextAttr.text = topText as NSString!
						self.topField.stringValue = topText
					}
				} else if (topbottom == 9) {
					if let bottomText = meme.bottomText {
						self.bottomTextAttr.text = bottomText as NSString!
						self.bottomField.stringValue = bottomText
					}
				}
				self.cookImage()
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kTextColorPanelNotification), object: nil, queue: queue) { (notification) in
			let panel = NSColorPanel.shared()
			panel.setTarget(self)
			self.textColorChange = true
			panel.setAction(#selector(EditorViewController.changeColor(_:)))
			panel.color = self.topTextAttr.textColor
			panel.runToolbarCustomizationPalette(self)
			panel.title = "Text Color"
			panel.makeKeyAndOrderFront(self)
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kOutlineColorPanelNotification), object: nil, queue: queue) { (notification) in
			let panel = NSColorPanel.shared()
			panel.setTarget(self)
			self.textColorChange = false
			panel.setAction(#selector(EditorViewController.changeColor(_:)))
			panel.color = self.topTextAttr.outlineColor
			panel.runToolbarCustomizationPalette(self)
			panel.title = "Outline Color"
			panel.makeKeyAndOrderFront(self)
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kUpdateAttributesNotification), object: nil, queue: queue) { (notification) in
			guard let userInfo = (notification as NSNotification).userInfo else { return }
			if let topAttr = userInfo[kTopAttrName] as? XTextAttributes {
				self.topTextAttr = topAttr
			}
			if let bottomAttr = userInfo[kBottomAttrName] as? XTextAttributes {
				self.bottomTextAttr = bottomAttr
			}
			self.cookImage()
		}
		
		center.addObserver(forName: NSNotification.Name.NSWindowDidResize, object: nil, queue: queue) { (notification) in
			let viewSize = self.view.bounds
			self.imageViewWidthConstraint.constant = viewSize.width - 16
			self.imageViewHeightConstraint.constant = viewSize.height - 96
			self.view.needsLayout = true
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kShareNotification), object: nil, queue: queue) { (notification) in
			if let image = self.imageView.image {
				let shareItems = [image, "Check out this meme I made."] as [Any]
				let sharingServicePicker = NSSharingServicePicker(items: shareItems)
				sharingServicePicker.delegate = self
				sharingServicePicker.show(relativeTo: NSMakeRect(self.topField.bounds.size.width - 36, 0, 0, 0), of: self.topField, preferredEdge: .maxY)
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kPrintNotification), object: nil, queue: queue) { (notification) in
			let printInfo = NSPrintInfo.shared()
			printInfo.leftMargin = 2
			printInfo.rightMargin = 2
			printInfo.topMargin = 2
			printInfo.bottomMargin = 2
			printInfo.orientation = .landscape
			let op = NSPrintOperation.init(view: self.imageView, printInfo: printInfo)
			op.runModal(for: self.view.window!, delegate: nil, didRun: nil, contextInfo: nil)
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kOpenNotification), object: nil, queue: queue) { (notification) in
			let openPanel = NSOpenPanel()
			openPanel.allowedFileTypes = ["jpg", "png", "gif", "jpeg", "jp2", "tiff"]
			openPanel.allowsMultipleSelection = false
			if openPanel.runModal() == NSModalResponseOK {
				if let URL = openPanel.url {
					if let data = try? Data(contentsOf: URL) {
						let image = NSImage(data: data)
						self.baseImage = image
						self.imageView.image = image
						self.cookImage()
					}
				}
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kSaveNotification), object: nil, queue: queue) { (notification) in
			let savePanel = NSSavePanel()
			savePanel.allowedFileTypes = ["jpg"]
			savePanel.canCreateDirectories = true
			savePanel.canSelectHiddenExtension = true
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd 'at' hh.mm.ss a"
			let memeName = self.imageView.memeName.characters.count > 0 ? self.imageView.memeName : "Meme"
			savePanel.nameFieldStringValue = memeName! + " " + formatter.string(from: Date())
			savePanel.title = "Save"
			if savePanel.runModal() == NSModalResponseOK {
				let bitmapImageRep = NSBitmapImageRep(data: (self.imageView.image?.tiffRepresentation)!)
				if let data = bitmapImageRep?.representation(using: .JPEG, properties: [NSImageCompressionFactor: NSNumber.init(value: 0.7 as Float)]) {
					try? data.write(to: savePanel.url!, options: [.atomic])
				}
			}
		}

		/*
		center.addObserverForName(kUndoNotification, object: nil, queue: queue) { (notification) in
			let (topA, bottomA) = self.xUndoManager.undo()
			if let topAttr = topA {
				self.topTextAttr = topAttr
			}
			if let bottomAttr = bottomA {
				self.bottomTextAttr = bottomAttr
			}
			self.cookImage()
		}
		
		center.addObserverForName(kRedoNotification, object: nil, queue: queue) { (notification) in
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
	
	func dragDropImageView(_ imageView: DragDropImageView!, didFinishDropAtFilePath filePath: String!, andImage image: NSImage!) {
		// Don't create a new meme object; just change the base image
		baseImage = image
		saveLastImage(image)
		imageView.memeName = ""
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(200	* Int64(USEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
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
		let maxHeight = (imageSize?.height)!/2 - 8	// Max height of top and bottom texts
		let stringDrawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin]
		
		let topText = topTextAttr.uppercase ? topTextAttr.text.uppercased : topTextAttr.text;
		let bottomText = bottomTextAttr.uppercase ? bottomTextAttr.text.uppercased : bottomTextAttr.text;
		
		topTextAttr.rect = CGRect(x: 4, y: (imageSize?.height)! - maxHeight - 8, width: (imageSize?.width)! - 8, height: maxHeight);
		var topTextRect = topText.boundingRect(with: CGSize(width: imageSize.width - 8, height: 1000), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
//
		// Adjust top size
		while (ceil(topTextRect.size.height) > maxHeight) {
			topTextAttr.fontSize -= 1;
			topTextRect = topText.boundingRect(with: CGSize(width: imageSize.width - 8, height: 1000), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
		}
		
		var bottomTextRect = bottomText.boundingRect(with: CGSize(width: imageSize.width - 8, height: 1000), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
		var expectedBottomSize = bottomTextRect.size
		bottomTextAttr.rect = CGRect(x: 4, y: 0, width: imageSize.width - 8, height: expectedBottomSize.height)
		
		// Adjust bottom size
		while (ceil(bottomTextRect.size.height) > maxHeight) {
			bottomTextAttr.fontSize -= 2;
			bottomTextRect = bottomText.boundingRect(with: CGSize(width: imageSize.width - 8, height: 1000), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
			expectedBottomSize = bottomTextRect.size
			bottomTextAttr.rect = CGRect(x: 4, y: 0, width: imageSize.width - 8, height: expectedBottomSize.height)
		}
		
		let offScreenRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int((imageSize?.width)!), pixelsHigh: Int((imageSize?.height)!), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bitmapFormat: NSBitmapFormat.alphaFirst, bytesPerRow: 0, bitsPerPixel: 0)
		
		let context = NSGraphicsContext(bitmapImageRep: offScreenRep!)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrent(context)
		
		baseImage?.draw(in: NSMakeRect(0, 0, (imageSize?.width)!, (imageSize?.height)!))
		
		let topRect = CGRect(x: topTextAttr.rect.origin.x + topTextAttr.offset.x, y: topTextAttr.rect.origin.y + topTextAttr.offset.y, width: topTextAttr.rect.size.width, height: topTextAttr.rect.size.height)
		let bottomRect = CGRect(x: bottomTextAttr.rect.origin.x + bottomTextAttr.offset.x, y: bottomTextAttr.rect.origin.y + bottomTextAttr.offset.y, width: bottomTextAttr.rect.size.width, height: bottomTextAttr.rect.size.height)
		
		topTextAttr.saveAttributes("topAttr")
		bottomTextAttr.saveAttributes("bottomAttr")
		
		topText.draw(in: NSRectFromCGRect(topRect), withAttributes: topTextAttr.getTextAttributes())
		bottomText.draw(in: NSRectFromCGRect(bottomRect), withAttributes: bottomTextAttr.getTextAttributes())
		
		NSGraphicsContext.restoreGraphicsState()
		
		let newImage = NSImage.init(size: NSSizeFromCGSize(imageSize!))
		newImage.addRepresentation(offScreenRep!)
		
		imageView.image = newImage
		
	}
	
}

// MARK: - Attribute control

extension EditorViewController {
	
	@IBAction func topAlignmentChange(_ sender: NSSegmentedControl) {
		let alignment = sender.selectedSegment
		topTextAttr.absAlignment = alignment
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func topSizeChange(_ sender: NSSegmentedControl) {
		topTextAttr.fontSize += ((sender.selectedSegment == 0) ? -2 : 2) * self.ratio;
		topTextAttr.fontSize = max(topTextAttr.fontSize, 12 * self.ratio)
		topTextAttr.fontSize = min(topTextAttr.fontSize, 144 * self.ratio)
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func bottomAlignmentChange(_ sender: NSSegmentedControl) {
		let alignment = sender.selectedSegment
		bottomTextAttr.absAlignment = alignment
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func bottomSizeChange(_ sender: NSSegmentedControl) {
		bottomTextAttr.fontSize += ((sender.selectedSegment == 0) ? -2 : 2) * self.ratio;
		bottomTextAttr.fontSize = max(bottomTextAttr.fontSize, 12 * self.ratio)
		bottomTextAttr.fontSize = min(bottomTextAttr.fontSize, 144 * self.ratio)
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	@IBAction func fillDefaultTextAction(_ sender: NSSegmentedControl) {
		let tag = sender.tag
		NotificationCenter.default.post(name: Notification.Name(rawValue: kFillDefaultTextNotification), object: nil, userInfo: ["topbottom": Int(tag)])
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	override func changeFont(_ sender: Any?) {
		if let topFont = (sender? as AnyObject).convert(topTextAttr.font) {
			topTextAttr.font = topFont
		}
		if let bottomFont = (sender? as AnyObject).convert(bottomTextAttr.font) {
			bottomTextAttr.font = bottomFont
		}
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
	override func changeColor(_ sender: Any?) {
		if (textColorChange) {
			topTextAttr.textColor = ((sender as AnyObject).color)!
			bottomTextAttr.textColor = ((sender as AnyObject).color)!
		} else {
			topTextAttr.outlineColor = ((sender as AnyObject).color)!
			bottomTextAttr.outlineColor = ((sender as AnyObject).color)!
		}
		cookImage()
//		xUndoManager.append(XTextAttributes(savename: "topAttr"), bottomAttr: XTextAttributes(savename: "bottomAttr"))
	}
	
}

// MARK: - Gesture and key control

extension EditorViewController: NSGestureRecognizerDelegate {
	
	func handlePinch(_ recognizer: NSMagnificationGestureRecognizer) -> Void {
		let fontScale = recognizer.magnification
		let point = recognizer.location(in: self.imageView)
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
	
	func handlePan(_ recognizer: NSPanGestureRecognizer) -> Void {
		let translation = recognizer.translation(in: self.imageView)
		if (movingTop) {
			topTextAttr.offset = CGPoint(x: topTextAttr.offset.x + ratio * recognizer.velocity(in: self.imageView).x/50,
			                                 y: topTextAttr.offset.y + ratio * recognizer.velocity(in: self.imageView).y/50);
		}
		else {
			bottomTextAttr.offset = CGPoint(x: bottomTextAttr.offset.x + ratio * recognizer.velocity(in: self.imageView).x/50,
			                                    y: bottomTextAttr.offset.y + ratio * recognizer.velocity(in: self.imageView).y/50);
		}
		recognizer.setTranslation(translation, in: imageView)
		cookImage()
	}
	
	func handleDoubleClick(_ recognizer: NSClickGestureRecognizer) -> Void {
		topTextAttr.uppercase = !topTextAttr.uppercase
		bottomTextAttr.uppercase = !bottomTextAttr.uppercase
		cookImage()
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
		if (!shouldDragText) { return false; }
		if (gestureRecognizer == self.panGestureRecognizer) {
			let topRect = NSMakeRect(0, (self.imageView.bounds.size.height)/2, (self.imageView.bounds.size.width), (self.imageView.bounds.size.height)/2)
			let location = gestureRecognizer.location(in: imageView)
			movingTop = (topRect.contains(location))
		}
		return true
	}
	
	override func flagsChanged(with theEvent: NSEvent) {
		let rawValue = theEvent.modifierFlags.rawValue
		shouldDragText = (rawValue/1000 == 524)
	}
	
}

extension EditorViewController: NSTextFieldDelegate {
	
	override func controlTextDidChange(_ obj: Notification) {
		topTextAttr.text = "\(topField.stringValue)" as NSString!
		topTextAttr.saveAttributes("topAttr")
		bottomTextAttr.text = "\(bottomField.stringValue)" as NSString!
		bottomTextAttr.saveAttributes("bottomAttr")
		cookImage()
	}
}

extension EditorViewController: NSSharingServicePickerDelegate {
	
}
