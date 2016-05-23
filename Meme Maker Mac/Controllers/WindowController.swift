//
//  WindowController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
		
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		
//		if let window = window, let screen = NSScreen.mainScreen() {
//			let screenRect = screen.visibleFrame
//			window.setFrame(NSRect(x: screenRect.origin.x, y: screenRect.origin.y, width: screenRect.width/2.0, height: screenRect.height), display: true)
//		}
		
    }
	
	// MARK: - Toolbar actions
	
	@IBAction func gridViewToggleAction(sender: AnyObject) {
		print("Toggling grid view!")
	}
	
	@IBAction func fontToolbarAction(sender: AnyObject) {
		
	}
	
	@IBAction func colorsToolbarAction(sender: AnyObject) {
		
	}
	
	

}
