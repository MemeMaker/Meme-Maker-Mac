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
	
	private var gridMode: Bool = true;
	
	@IBOutlet weak var veView: NSVisualEffectView!

	override func viewDidLoad() {
		super.viewDidLoad()
	
		configureCollectionView()
		
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
		
		self.fetchLocalMemes()
		
		handleNotifications()
		
		if (NSDate().timeIntervalSinceDate(SettingsManager.getLastUpdateDate())) > 7 * 86400 {
			print("Fetching latest memes, just for you!")
			let fetcher = MemeFetcher()
			fetcher.fetchMemes()
		}
		
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NSNotificationCenter.defaultCenter().postNotificationName(kDarkModeChangedNotification, object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	func fetchLocalMemes() -> Void {
		let request = NSFetchRequest(entityName: "XMeme")
		
		let sortMode = SettingsManager.getInteger(kSettingsLastSortKey)
		if (sortMode == 1) { // Default
			request.sortDescriptors =  [NSSortDescriptor.init(key: "memeID", ascending: true)]
		} else if (sortMode == 2) { // Alphabetical
			request.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
		} else {
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
		var searchText = ""
		if let text = SettingsManager.getObject(kSettingsLastSearchKey) {
			searchText = text as! String
		}
		self.filterMemesWithSearchText(searchText)
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
		collectionView.layer?.backgroundColor = NSColor.clearColor().CGColor
		collectionScrollView.wantsLayer = true
		collectionScrollView.layer?.cornerRadius = 4
		collectionScrollView.layer?.backgroundColor = NSColor.clearColor().CGColor
}
	
	func handleNotifications() -> Void {
		
		let center = NSNotificationCenter.defaultCenter()
		
		center.addObserverForName(NSWindowDidResizeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.collectionView.reloadData()
		}
		
		center.addObserverForName(kToggleViewModeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notificaton) in
			if let dict = notificaton.userInfo {
				let mode = dict[kToggleViewModeKey]
				self.gridMode = mode!.boolValue
				self.collectionView.reloadData()
			}
		}
		
		center.addObserverForName(kFetchCompleteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			self.fetchLocalMemes()
		}
		
		center.addObserverForName(kSortModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let sortMode = SettingsManager.getInteger(kSettingsLastSortKey)
			if (sortMode == 1) { // Default
				self.memes.sortUsingDescriptors([NSSortDescriptor.init(key: "memeID", ascending: true)])
			} else if (sortMode == 2) { // Alphabetical
				self.memes.sortUsingDescriptors([NSSortDescriptor.init(key: "name", ascending: true)])
			} else if (sortMode == 3) { // Rank wise
				self.memes.sortUsingDescriptors([NSSortDescriptor.init(key: "rank", ascending: true)])
			}
			self.collectionView.reloadData()
		}
		
		center.addObserverForName(kSearchBarTextChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			if let dict = notification.userInfo {
				if let searchText = dict[kSettingsLastSearchKey] as? String {
					self.filterMemesWithSearchText(searchText)
				}
			}
		}
		
		center.addObserverForName(kDarkModeChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .Dark : .Light
			self.collectionView.reloadData()
		}
		
	}
	
	func isGrid () -> Bool {
		return gridMode
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "editorSegue") {
			guard let editorVC = segue.destinationController  as? EditorViewController else { return }
			self.editorVC = editorVC
			/*
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 333 * Int64(USEC_PER_SEC)), dispatch_get_main_queue(), {
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
			*/
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
	
	func filterMemesWithSearchText(searchText: String!) {
		memes = allMemes.mutableCopy() as! NSMutableArray
		if (searchText.characters.count > 0) {
			memes.filterUsingPredicate(NSPredicate(format: "name contains[cd] %@ OR tags contains[cd] %@", searchText, searchText))
		}
		collectionView.reloadData()
	}
	
}
