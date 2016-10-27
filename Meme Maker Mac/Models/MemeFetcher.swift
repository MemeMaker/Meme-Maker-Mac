//
//  MemeFetcher.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/6/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

open class MemeFetcher: NSObject {
	
	fileprivate var context: NSManagedObjectContext? = nil
	
	fileprivate var memes = NSMutableArray()
	fileprivate var fetchedMemes = NSMutableArray()
	
	override init() {
		super.init()
		let appDelegate = NSApplication.shared().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
	}
	
	open func fetchMemes() -> Void {
		fetchMemes(0)
	}
	
	fileprivate func fetchMemes(_ paging: Int) -> Void {
		var request = URLRequest(url: apiMemesPaging(paging))
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if (error != nil) {
				dump(error)
				return
			}
			if (data != nil) {
				do {
					let persistentStoreCoordinator = self.context?.persistentStoreCoordinator
					let asyncContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
					asyncContext.persistentStoreCoordinator = persistentStoreCoordinator
					
					let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
                    // TODO: add proper error checks here to protect against getting an unexpected json format
					let code = json!["code"] as! Int
					if (code == 200) {
						let jsonmemes = json!["data"] as! NSArray
						let memesArray = XMeme.getAllMemesFromArray(jsonmemes, context: asyncContext)!
						for meme in memesArray {
							self.fetchedMemes.add(meme)
						}
						try asyncContext.save()
						DispatchQueue.main.async(execute: {
							self.fetchMemes(paging + 1)
						})
					}
					else {
						self.memes = self.fetchedMemes
						print("Fetch complete!")
						DispatchQueue.main.async(execute: {
							SettingsManager.saveLastUpdateDate()
							NotificationCenter.default.post(name: Notification.Name(rawValue: kFetchCompleteNotification), object: nil, userInfo: ["memes": self.memes])
						})
						return
					}
				}
				catch _ {
					print("Unable to parse")
					return
				}
			}
			}).resume()
		
	}

}
