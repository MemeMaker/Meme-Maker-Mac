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
	@IBOutlet weak var collectionScrollView: NSScrollView!
	
	var editorVC: EditorViewController!
	
	var memes = NSMutableArray()
	var allMemes = NSMutableArray()
	
	var context: NSManagedObjectContext? = nil
	
	@IBOutlet weak var searchField: NSSearchField!
	
	private var gridMode: Bool = true;

	override func viewDidLoad() {
		super.viewDidLoad()
	
		configureCollectionView()
		
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
		
		self.fetchLocalMemes()
	
		NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidResizeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.collectionView.reloadData()
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(kToggleViewModeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notificaton) in
			let dict = notificaton.userInfo
			let mode = dict![kToggleViewModeKey] as! NSNumber
			self.gridMode = mode.boolValue
			self.collectionView.reloadData()
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(kFetchCompleteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.fetchLocalMemes()
		}
		
		if (NSDate().timeIntervalSinceDate(SettingsManager.getLastUpdateDate())) > 7 * 86400 {
			print("Fetching latest memes, just for you!")
			let fetcher = MemeFetcher()
			fetcher.fetchMemes()
		}
		
	}
	
	func fetchLocalMemes() -> Void {
		let request = NSFetchRequest(entityName: "XMeme")
		if let lastSortKey = SettingsManager.getObject(kSettingsLastSortKey) {
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
		self.filterMemesWithSearchText(self.searchField.stringValue)
	}
	
	private func configureCollectionView() {
		// 1
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.itemSize = NSSize(width: 60.0, height: 60.0)
		flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.minimumInteritemSpacing = 0
		flowLayout.minimumLineSpacing = 0
		collectionView.collectionViewLayout = flowLayout
		collectionView.reloadData()
		collectionView.wantsLayer = true
		collectionView.layer?.cornerRadius = 4
		collectionScrollView.wantsLayer = true
		collectionScrollView.layer?.cornerRadius = 4
	}
	
	func isGrid () -> Bool {
		return gridMode
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "editorSegue") {
			guard let editorVC = segue.destinationController  as? EditorViewController else { return }
			self.editorVC = editorVC
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1/3 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
				let lastMemeID = SettingsManager.getInteger(kSettingsLastMemeIdOpened)
				let fetchRequest = NSFetchRequest(entityName: "XMeme")
				fetchRequest.predicate = NSPredicate(format: "memeID == %li", lastMemeID)
				do {
					let fetchedArray = try self.context!.executeFetchRequest(fetchRequest)
					if (fetchedArray.count > 0) {
						if let meme = fetchedArray.first as? XMeme {
							self.editorVC.meme = meme
						}
					}
				}
				catch _ {
					
				}
			})

		}
	}
	
}

// MARK: - Collection view data source

extension ViewController : NSCollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return memes.count
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
		
		if !isGrid() {
			collectionViewItem.gray = (indexPath.item % 2 == 1)
		}
		
		let meme = memes.objectAtIndex(indexPath.item) as! XMeme
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
		guard let indexPath = indexPaths.first else { return }
		guard let item = collectionView.itemAtIndexPath(indexPath) else { return }
		(item as! BaseCollectionViewItem).setHighlight(true)
		guard let meme = memes[indexPath.item] as? XMeme else { return }
//		XTextAttributes.clearTopAndBottomTexts() // Maybe don't clear them?
		SettingsManager.setInteger(Int(meme.memeID), key: kSettingsLastMemeIdOpened)
		self.editorVC.meme = meme
		self.editorVC.cookImage()
	}
	
	func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
		guard let indexPath = indexPaths.first else { return }
		guard let item = collectionView.itemAtIndexPath(indexPath) else { return }
		(item as! BaseCollectionViewItem).setHighlight(false)
	}
	
	func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
		let width = collectionView.frame.size.width
		if (isGrid()) {
			var nr: CGFloat = 4
			if width < 300 { nr = 3 }
			else if width < 400 { nr = 4 }
			else if width < 500 { nr = 5 }
			else { nr = 6 }
			let size = CGSizeMake(collectionView.frame.size.width/nr, collectionView.frame.size.width/nr)
			return NSSizeFromCGSize(size)
		}
		return NSSizeFromCGSize(CGSizeMake(width, 60))
	}
	
}

extension ViewController: NSSearchFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		self.filterMemesWithSearchText(self.searchField.stringValue)
	}
	
	func filterMemesWithSearchText(searchText: String!) {
		memes = allMemes.mutableCopy() as! NSMutableArray
		if (searchText.characters.count > 0) {
			memes.filterUsingPredicate(NSPredicate(format: "name contains[cd] %@ OR tags contains[cd] %@", searchText, searchText))
		}
		collectionView.reloadData()
	}
	
}
