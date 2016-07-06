//
//  BaseCollectionViewItem.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/23/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa
import CoreGraphics

class BaseCollectionViewItem: NSCollectionViewItem {
	
	var meme: XMeme? {
		didSet {
			if let meme = meme {
				updateImageView()
				textField?.stringValue = "\(meme.name!)"
			}
		}
	}
	
	var gray: Bool = false {
		didSet {
			if gray {
				self.view.layer?.backgroundColor = NSColor.controlHighlightColor().CGColor
			} else {
				self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.wantsLayer = true
	}
	
}

// MARK: - Downloading and updation

extension BaseCollectionViewItem {

	func updateImageView() -> Void {
		let filePath = imagesPathForFileName("\(self.meme!.memeID)")
		let filePathS = imagesPathForFileName("\(self.meme!.memeID)s")
		if (NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
			if let image = NSImage.init(contentsOfFile: filePathS) {
				imageView?.image = image
			}
			else {
				if let image = NSImage.init(contentsOfFile: filePath) {
					let squareImage = squareImageFromImage(image)
					let bitmapImageRep = NSBitmapImageRep(data: squareImage.TIFFRepresentation!)
					if let data = bitmapImageRep?.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: NSNumber.init(float: 0.7)]) {
						data.writeToFile(filePathS, atomically: true)
					}
					imageView?.image = squareImage;
				}
			}
		} else {
			self.imageView?.image = NSImage(named: "MemeBlank")
			if let URLString = meme?.image {
				if let URL = NSURL(string: URLString) {
					print("Downloading image \'\(meme!.memeID)\'")
					self.downloadImageWithURL(URL, filePath: filePath)
				}
			}
		}
	}
	
	func downloadImageWithURL(URL: NSURL, filePath: String) -> Void {
		
		NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
			if (error == nil) {
				if let data = data {
					data.writeToFile(filePath, atomically: true)
					dispatch_async(dispatch_get_main_queue(), {
						self.updateImageView()
					})
				}
			}
		}.resume()
 	}
	
}

// MARK: - Cropping utils

extension BaseCollectionViewItem {

	func squareImageFromImage(image: NSImage) -> NSImage {
		let minwh = Double(min(image.size.width, image.size.height))
		return cropToBounds(image, width: minwh, height: minwh)
	}
	
	func cropToBounds(image: NSImage, width: Double, height: Double) -> NSImage {
		var imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
		let contextImage: NSImage =  NSImage.init(CGImage: image.CGImageForProposedRect(&imageRect, context: nil, hints: nil)!, size: imageRect.size)
		let contextSize: CGSize = contextImage.size
		var posX: CGFloat = 0.0
		var posY: CGFloat = 0.0
		var cgwidth: CGFloat = CGFloat(width)
		var cgheight: CGFloat = CGFloat(height)
		// See what size is longer and create the center off of that
		if contextSize.width > contextSize.height {
			posX = ((contextSize.width - contextSize.height) / 2)
			posY = 0
			cgwidth = contextSize.height
			cgheight = contextSize.height
		}
		else {
			posX = 0
			posY = ((contextSize.height - contextSize.width) / 2)
			cgwidth = contextSize.width
			cgheight = contextSize.width
		}
		let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
		// Create bitmap image from context using the rect
		let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
			, rect)!
		// Create a new image based on the imageRef and rotate back to the original orientation
		let image: NSImage = NSImage.init(CGImage: imageRef, size: rect.size)
		return image
	}
	
	func setHighlight(selected: Bool) {
		// Must be overridde in subclass
	}
    
}
