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
	
	var meme: XMeme!  {
		didSet {
			
			var topText = "\(meme.topText)"
			if topText != "nil" { topText = "\(meme!.topText!)" }
			else { topText = "" }
			topField.stringValue = topText
			
			var bottomText = "\(meme.bottomText)"
			if bottomText != "nil" { bottomText = "\(meme!.bottomText!)" }
			else { bottomText = "" }
			bottomField.stringValue = bottomText
			
			if let image = NSImage.init(contentsOfFile: imagesPathForFileName("\(meme.memeID)")) {
				imageView?.image = image
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
