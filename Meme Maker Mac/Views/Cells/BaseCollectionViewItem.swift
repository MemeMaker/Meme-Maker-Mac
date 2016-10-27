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
			updateBackground()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.wantsLayer = true
	}
	
	func updateBackground() -> Void {
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		let pc = darkMode ? 82.0 : 212.0 as CGFloat
		let ac = pc + 30.0 as CGFloat
		if gray {
			self.view.layer?.backgroundColor = NSColor(red: pc/255, green: pc/255, blue: pc/255, alpha: 0.3).cgColor
		} else {
			self.view.layer?.backgroundColor = NSColor(red: ac/255, green: ac/255, blue: ac/255, alpha: 0.3).cgColor
		}
	}

}

// MARK: - Downloading and updation

extension BaseCollectionViewItem {

	func updateImageView() -> Void {
		let filePath = imagesPathForFileName("\(self.meme!.memeID)")
		let filePathS = imagesPathForFileName("\(self.meme!.memeID)s")
		if (FileManager.default.fileExists(atPath: filePath)) {
			if let image = NSImage.init(contentsOfFile: filePathS) {
				imageView?.image = image
			}
			else {
				if let image = NSImage.init(contentsOfFile: filePath) {
					let squareImage = squareImageFromImage(image)
					let bitmapImageRep = NSBitmapImageRep(data: squareImage.tiffRepresentation!)
					if let data = bitmapImageRep?.representation(using: .JPEG, properties: [NSImageCompressionFactor: NSNumber.init(value: 0.7 as Float)]) {
						try? data.write(to: URL(fileURLWithPath: filePathS), options: [.atomic])
					}
					imageView?.image = squareImage;
				}
			}
		} else {
			self.imageView?.image = NSImage(named: "MemeBlank")
			if let URLString = meme?.image {
				if let URL = URL(string: URLString) {
					print("Downloading image \'\(meme!.memeID)\'")
					self.downloadImageWithURL(URL, filePath: filePath)
				}
			}
		}
	}
	
	func downloadImageWithURL(_ URL: Foundation.URL, filePath: String) -> Void {
		
		URLSession.shared.dataTask(with: URL, completionHandler: { (data, response, error) in
			if (error == nil) {
				if let data = data {
					try? data.write(to: Foundation.URL(fileURLWithPath: filePath), options: [.atomic])
					DispatchQueue.main.async(execute: {
						self.updateImageView()
					})
				}
			}
		}) .resume()
 	}
	
}

// MARK: - Cropping utils

extension BaseCollectionViewItem {

	func squareImageFromImage(_ image: NSImage) -> NSImage {
		let minwh = Double(min(image.size.width, image.size.height))
		return cropToBounds(image, width: minwh, height: minwh)
	}
	
	func cropToBounds(_ image: NSImage, width: Double, height: Double) -> NSImage {
		var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
		let contextImage: NSImage =  NSImage.init(cgImage: image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!, size: imageRect.size)
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
		let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
		// Create bitmap image from context using the rect
		let imageRef: CGImage = contextImage.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!.cropping(to: rect)!
		// Create a new image based on the imageRef and rotate back to the original orientation
		let image: NSImage = NSImage.init(cgImage: imageRef, size: rect.size)
		return image
	}
	
	func setHighlight(_ selected: Bool) {
		// Must be overridde in subclass
	}
    
}
