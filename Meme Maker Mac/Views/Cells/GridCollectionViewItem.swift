//
//  GridCollectionViewItem.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class GridCollectionViewItem: NSCollectionViewItem {
	
	var image: NSImage? {
		didSet {
			guard viewLoaded else { return }
			if let image = image {
				imageView?.image = image
			}
			else {
				imageView?.image = nil
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		view.wantsLayer = true
		
		// Customize layer
		view.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
		view.layer?.borderWidth = 0.0
		view.layer?.borderColor = NSColor.whiteColor().CGColor
		
    }
	
	func setHighlight(selected: Bool) {
		view.layer?.borderWidth = selected ? 5.0 : 0.0
	}
	
}
