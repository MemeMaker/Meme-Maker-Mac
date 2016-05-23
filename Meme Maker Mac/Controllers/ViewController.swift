//
//  ViewController.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	var memes = NSMutableArray()
	var allMemes = NSMutableArray()
	var fetchedMemes = NSMutableArray()
	
	var context: NSManagedObjectContext? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureCollectionView()
		
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
		
		self.fetchLocalMemes()
		
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

	// MARK: - Collection view data source
	
	func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return allMemes.count
	}
	
	func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
		
		let item = collectionView.makeItemWithIdentifier("GridCollectionViewItem", forIndexPath: indexPath)
		guard let collectionViewItem = item as? BaseCollectionViewItem else {return item}
		
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
	
	// MARK: - Collection view delegate
	
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
	
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
}

