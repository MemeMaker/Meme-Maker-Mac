//
//  ViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	var memes = NSMutableArray()
	var allMemes = NSMutableArray()
	var fetchedMemes = NSMutableArray()
	
	var windowController: WindowController?
	
	var context: NSManagedObjectContext? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let windowController = NSApplication.sharedApplication().keyWindow?.windowController as? WindowController {
			windowController.delegate = self
			self.windowController = windowController
		}
		
		configureCollectionView()
		
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
		
		self.fetchLocalMemes()
	
		NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidResizeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.collectionView.reloadData()
		}
		
	}
	
	func fetchLocalMemes() -> Void {
		let request = NSFetchRequest(entityName: "XMeme")
		if let lastSortKey = SettingsManager.sharedManager().getObject(kSettingsLastSortKey) {
			request.sortDescriptors = [NSSortDescriptor.init(key: lastSortKey as? String, ascending: true)]
		}
		else {
			request.sortDescriptors = [NSSortDescriptor.init(key: "rank", ascending: true)]
		}
		do {
			let fetchedArray = try self.context?.executeFetchRequest(request)
			memes = NSMutableArray(array: fetchedArray!)
			allMemes = NSMutableArray(array: fetchedArray!)
		}
		catch _ {
			print("Error in fetching.")
		}
		
		self.collectionView.reloadData()
		
//		memesPerRow = SettingsManager.sharedManager().getInteger(kSettingsNumberOfElementsInGrid)
//		isListView = SettingsManager.sharedManager().getBool(kSettingsViewModeIsList)
//		updateCollectionViewCells()
//		
//		self.filterMemesWithSearchText(self.searchBar.text!)
	}
	
	private func configureCollectionView() {
		// 1
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.itemSize = NSSize(width: 60.0, height: 60.0)
		flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.minimumInteritemSpacing = 0
		flowLayout.minimumLineSpacing = 0
		collectionView.collectionViewLayout = flowLayout
//		collectionView.wantsLayer = true
//		collectionView.layer?.backgroundColor = NSColor.blackColor().CGColor
		collectionView.reloadData()
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	func isGrid () -> Bool {
		if let windowController = windowController {
			return windowController.grid
		}
		return true
	}
	
}

// MARK: - Collection view data source

extension ViewController : NSCollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return allMemes.count
	}
	
	func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
		
		// Change between list and grid!
		var item = NSCollectionViewItem()
		if isGrid() {
			item = collectionView.makeItemWithIdentifier("GridCollectionViewItem", forIndexPath: indexPath)
		}
		else {
			item = collectionView.makeItemWithIdentifier("ListCollectionViewItel", forIndexPath: indexPath)
		}
		guard let collectionViewItem = item as? BaseCollectionViewItem else { return item }
		
		let meme = allMemes.objectAtIndex(indexPath.item) as! XMeme
		collectionViewItem.meme = meme
		
		if let selectedIndexPath = collectionView.selectionIndexPaths.first where selectedIndexPath == indexPath {
			collectionViewItem.setHighlight(true)
		}
		else {
			collectionViewItem.setHighlight(false)
		}
		
		return item
	}
	
}

// MARK: - Collection view delegate

extension ViewController : NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
		guard let indexPath = indexPaths.first else {return}
		guard let item = collectionView.itemAtIndexPath(indexPath) else {return}
		(item as! BaseCollectionViewItem).setHighlight(true)
	}
	
	func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
		guard let indexPath = indexPaths.first else {return}
		guard let item = collectionView.itemAtIndexPath(indexPath) else {return}
		(item as! BaseCollectionViewItem).setHighlight(false)
	}
	
	func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
		let width = collectionView.frame.size.width
		if (isGrid()) {
			var nr: CGFloat = 4
			if width < 400 { nr = 3 }
			else if width < 500 { nr = 4 }
			else if width < 600 { nr = 5 }
			else { nr = 6 }
			let size = CGSizeMake(collectionView.frame.size.width/nr, collectionView.frame.size.width/nr)
			return NSSizeFromCGSize(size)
		}
		return NSSizeFromCGSize(CGSizeMake(width, 60))
	}
	
}

// MARK: - Window controller delegate

extension ViewController : WindowControllerDelegate {
	
	func windowController(windowController: NSWindowController, didToggleGridView: Bool) {
		self.collectionView.reloadData()
	}
	
	func windowController(windowController: NSWindowController, didSelectFontToolbar: Bool) {
		
	}
	
	func windowController(windowController: NSWindowController, didSelectColorToolbar: Bool) {
		
	}
	
}
