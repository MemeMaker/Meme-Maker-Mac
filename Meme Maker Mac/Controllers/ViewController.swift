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
	
	fileprivate var gridMode: Bool = true;
	
	@IBOutlet weak var veView: NSVisualEffectView!

	override func viewDidLoad() {
		super.viewDidLoad()
	
		configureCollectionView()
		
		let appDelegate = NSApplication.shared().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
		
		self.fetchLocalMemes()
		
		handleNotifications()
		
		if (Date().timeIntervalSince(SettingsManager.getLastUpdateDate() as Date)) > 7 * 86400 {
			print("Fetching latest memes, just for you!")
			let fetcher = MemeFetcher()
			fetcher.fetchMemes()
		}
		
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let darkMode = SettingsManager.getBool(kSettingsDarkMode)
		NotificationCenter.default.post(name: Notification.Name(rawValue: kDarkModeChangedNotification), object: nil, userInfo: ["darkMode": Bool(darkMode)])
	}
	
	func fetchLocalMemes() -> Void {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "XMeme")
		
		let sortMode = SettingsManager.getInteger(kSettingsLastSortKey)
		if (sortMode == 1) { // Default
			request.sortDescriptors =  [NSSortDescriptor.init(key: "memeID", ascending: true)]
		} else if (sortMode == 2) { // Alphabetical
			request.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
		} else {
			request.sortDescriptors = [NSSortDescriptor.init(key: "rank", ascending: true)]
		}
		do {
			let fetchedArray = try self.context?.fetch(request)
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
	
	fileprivate func configureCollectionView() {
		// 1
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.itemSize = NSSize(width: 60.0, height: 60.0)
		flowLayout.sectionInset = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.minimumInteritemSpacing = 0
		flowLayout.minimumLineSpacing = 0
		collectionView.collectionViewLayout = flowLayout
		collectionView.reloadData()
		collectionView.wantsLayer = true
		collectionView.layer?.cornerRadius = 4
		collectionView.layer?.backgroundColor = NSColor.clear.cgColor
		collectionScrollView.wantsLayer = true
		collectionScrollView.layer?.cornerRadius = 4
		collectionScrollView.layer?.backgroundColor = NSColor.clear.cgColor
}
	
	func handleNotifications() -> Void {
		
		let center = NotificationCenter.default
		
		center.addObserver(forName: NSNotification.Name.NSWindowDidResize, object: nil, queue: OperationQueue.main) { (notification) in
			self.collectionView.reloadData()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kToggleViewModeNotification), object: nil, queue: OperationQueue.main) { (notificaton) in
			if let dict = (notificaton as NSNotification).userInfo {
				let mode = dict[kToggleViewModeKey]
				self.gridMode = (mode! as AnyObject).boolValue
				self.collectionView.reloadData()
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kFetchCompleteNotification), object: nil, queue: OperationQueue.main) { (notification) in
			self.fetchLocalMemes()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kSortModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			let sortMode = SettingsManager.getInteger(kSettingsLastSortKey)
			if (sortMode == 1) { // Default
				self.memes.sort(using: [NSSortDescriptor.init(key: "memeID", ascending: true)])
			} else if (sortMode == 2) { // Alphabetical
				self.memes.sort(using: [NSSortDescriptor.init(key: "name", ascending: true)])
			} else if (sortMode == 3) { // Rank wise
				self.memes.sort(using: [NSSortDescriptor.init(key: "rank", ascending: true)])
			}
			self.collectionView.reloadData()
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kSearchBarTextChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			if let dict = (notification as NSNotification).userInfo {
				if let searchText = dict[kSettingsLastSearchKey] as? String {
					self.filterMemesWithSearchText(searchText)
				}
			}
		}
		
		center.addObserver(forName: NSNotification.Name(rawValue: kDarkModeChangedNotification), object: nil, queue: OperationQueue.main) { (notification) in
			let darkMode = SettingsManager.getBool(kSettingsDarkMode)
			self.veView.material = darkMode ? .dark : .light
			self.collectionView.reloadData()
		}
		
	}
	
	func isGrid () -> Bool {
		return gridMode
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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
	
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return memes.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		
		// Change between list and grid!
		var item = NSCollectionViewItem()
		if isGrid() {
			item = collectionView.makeItem(withIdentifier: "GridCollectionViewItem", for: indexPath)
		}
		else {
			item = collectionView.makeItem(withIdentifier: "ListCollectionViewItel", for: indexPath)
		}
		guard let collectionViewItem = item as? BaseCollectionViewItem else { return item }
		
		if !isGrid() {
			collectionViewItem.gray = ((indexPath as NSIndexPath).item % 2 == 1)
		}
		
		let meme = memes.object(at: (indexPath as NSIndexPath).item) as! XMeme
		collectionViewItem.meme = meme
		
		if let selectedIndexPath = collectionView.selectionIndexPaths.first, selectedIndexPath == indexPath {
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
	
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		guard let indexPath = indexPaths.first else { return }
		guard let item = collectionView.item(at: indexPath) else { return }
		(item as! BaseCollectionViewItem).setHighlight(true)
		guard let meme = memes[(indexPath as NSIndexPath).item] as? XMeme else { return }
//		XTextAttributes.clearTopAndBottomTexts() // Maybe don't clear them?
		SettingsManager.setInteger(Int(meme.memeID), key: kSettingsLastMemeIdOpened)
		self.editorVC.meme = meme
		self.editorVC.cookImage()
	}
	
	func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
		guard let indexPath = indexPaths.first else { return }
		guard let item = collectionView.item(at: indexPath) else { return }
		(item as! BaseCollectionViewItem).setHighlight(false)
	}
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		let width = collectionView.frame.size.width
		if (isGrid()) {
			var nr: CGFloat = 4
			if width < 300 { nr = 3 }
			else if width < 400 { nr = 4 }
			else if width < 500 { nr = 5 }
			else { nr = 6 }
			let size = CGSize(width: collectionView.frame.size.width/nr, height: collectionView.frame.size.width/nr)
			return NSSizeFromCGSize(size)
		}
		return NSSizeFromCGSize(CGSize(width: width, height: 60))
	}
	
}

extension ViewController: NSSearchFieldDelegate {
	
	func filterMemesWithSearchText(_ searchText: String!) {
		memes = allMemes.mutableCopy() as! NSMutableArray
		if (searchText.characters.count > 0) {
			memes.filter(using: NSPredicate(format: "name contains[cd] %@ OR tags contains[cd] %@", searchText, searchText))
		}
		collectionView.reloadData()
	}
	
}
