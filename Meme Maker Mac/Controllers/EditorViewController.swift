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
	
	var topTextAttr: XTextAttributes =  XTextAttributes(savename: "topAttr")
	var bottomTextAttr: XTextAttributes = XTextAttributes(savename: "bottomAttr")
	
	var meme: XMeme!  {
		didSet {
			
			topTextAttr.saveAttributes("topAttr")
			bottomTextAttr.saveAttributes("bottomAttr")
			
			topTextAttr.text = "\(topField.stringValue)"
			bottomTextAttr.text = "\(bottomField.stringValue)"
			cookImage()
			
			if let image = NSImage.init(contentsOfFile: imagesPathForFileName("\(meme.memeID)")) {
				imageView?.image = image
				baseImage = image
			}
		}
	}
	
	var baseImage: NSImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension EditorViewController {
	
	func cookImage() -> Void {
		if (baseImage == nil) {
			return;
		}
		let imageSize = baseImage?.size as CGSize!
		let maxHeight = imageSize.height/2 + 2	// Max height of top and bottom texts
		let stringDrawingOptions: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
		
		var topTextRect = topTextAttr.text.boundingRectWithSize(CGSizeMake(imageSize.width, maxHeight), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
		var expectedTopSize = topTextRect.size
		// Bottom rect starts from bottom, not from center.y
		topTextAttr.rect = CGRectMake(0, (imageSize.height) - (expectedTopSize.height), imageSize.width, expectedTopSize.height);
		// Adjust top size
		while (ceil(topTextRect.size.height) > maxHeight) {
			topTextAttr.fontSize -= 1;
			topTextRect = topTextAttr.text.boundingRectWithSize(CGSizeMake(imageSize.width, maxHeight), options: stringDrawingOptions, attributes: topTextAttr.getTextAttributes(), context: nil)
			expectedTopSize = topTextRect.size
			topTextAttr.rect = CGRectMake(0, (imageSize.height) - (expectedTopSize.height), imageSize.width, expectedTopSize.height)
		}
		
		var bottomTextRect = bottomTextAttr.text.boundingRectWithSize(CGSizeMake(imageSize.width, maxHeight), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
		bottomTextAttr.rect = CGRectMake(0, 0, imageSize.width, imageSize.height/2)
		
		// Adjust bottom size
		while (ceil(bottomTextRect.size.height) > maxHeight) {
			bottomTextAttr.fontSize -= 1;
			bottomTextRect = bottomTextAttr.text.boundingRectWithSize(CGSizeMake(imageSize.width, maxHeight), options: stringDrawingOptions, attributes: bottomTextAttr.getTextAttributes(), context: nil)
		}
		
		let offScreenRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageSize.width), pixelsHigh: Int(imageSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bitmapFormat: NSBitmapFormat.NSAlphaFirstBitmapFormat, bytesPerRow: 0, bitsPerPixel: 0)
		
		let context = NSGraphicsContext(bitmapImageRep: offScreenRep!)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrentContext(context)
		
		baseImage?.drawInRect(NSMakeRect(0, 0, imageSize.width, imageSize.height))
		
		let topText = topTextAttr.uppercase ? topTextAttr.text.uppercaseString : topTextAttr.text;
		let bottomText = bottomTextAttr.uppercase ? bottomTextAttr.text.uppercaseString : bottomTextAttr.text;
		
		let topRect = CGRectMake(topTextAttr.rect.origin.x + topTextAttr.offset.x, topTextAttr.rect.origin.y + topTextAttr.offset.y, topTextAttr.rect.size.width, topTextAttr.rect.size.height)
		let bottomRect = CGRectMake(bottomTextAttr.rect.origin.x + bottomTextAttr.offset.x, bottomTextAttr.rect.origin.y + bottomTextAttr.offset.y, bottomTextAttr.rect.size.width, bottomTextAttr.rect.size.height)
		
		topText.drawInRect(NSRectFromCGRect(topRect), withAttributes: topTextAttr.getTextAttributes())
		bottomText.drawInRect(NSRectFromCGRect(bottomRect), withAttributes: bottomTextAttr.getTextAttributes())
		
		NSGraphicsContext.restoreGraphicsState()
		
		let newImage = NSImage.init(size: NSSizeFromCGSize(imageSize))
		newImage.addRepresentation(offScreenRep!)
		
		imageView.image = newImage
		
	}
	
}

extension EditorViewController: NSTextFieldDelegate {
	
	@IBAction func topTextChanged(sender: NSTextField) {
//		topTextAttr.text = "\(topField.stringValue)"
//		topTextAttr.saveAttributes("topAttr")
//		cookImage()
	}
	
	@IBAction func bottomTextChanged(sender: NSTextField) {
//		bottomTextAttr.text = "\(bottomField.stringValue)"
//		bottomTextAttr.saveAttributes("bottomAttr")
//		cookImage()
	}
	
	override func controlTextDidChange(obj: NSNotification) {
		topTextAttr.text = "\(topField.stringValue)"
		topTextAttr.saveAttributes("topAttr")
		bottomTextAttr.text = "\(bottomField.stringValue)"
		bottomTextAttr.saveAttributes("bottomAttr")
		cookImage()
	}
}