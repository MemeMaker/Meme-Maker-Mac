//
//  BaseCollectionViewItem.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/23/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class BaseCollectionViewItem: NSCollectionViewItem {
	
	var meme: XMeme? {
		didSet {
			if let meme = meme {
				imageView?.image = NSImage.init(contentsOfFile: imagesPathForFileName("\(meme.memeID)"))
				textField?.stringValue = "\(meme.name!)"
			}
		}
	}
	
//	func squareImageFromImage(image: NSImage) -> NSImage {
//		
//	}
	
	func setHighlight(selected: Bool) {
		// Must be overridde in subclass
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
