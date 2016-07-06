//
//  MemeFetcher.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 7/6/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Cocoa

public class MemeFetcher: NSObject {
	
	private var context: NSManagedObjectContext? = nil
	
	private var memes = NSMutableArray()
	private var fetchedMemes = NSMutableArray()
	
	override init() {
		super.init()
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		context = appDelegate.managedObjectContext
	}
	
	public func fetchMemes() -> Void {
		fetchMemes(0)
	}
	
	private func fetchMemes(paging: Int) -> Void {
		let request = NSMutableURLRequest(URL: apiMemesPaging(paging))
		request.HTTPMethod = "GET"
		NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
			if (error != nil) {
				print("Error: %@", error?.localizedDescription)
				return
			}
			if (data != nil) {
				do {
					let persistentStoreCoordinator = self.context?.persistentStoreCoordinator
					let asyncContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
					asyncContext.persistentStoreCoordinator = persistentStoreCoordinator
					
					let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
					let code = json.valueForKey("code") as! Int
					if (code == 200) {
						let jsonmemes = json.valueForKey("data") as! NSArray
						let memesArray = XMeme.getAllMemesFromArray(jsonmemes, context: asyncContext)!
						for meme in memesArray {
							self.fetchedMemes.addObject(meme)
						}
						try asyncContext.save()
						dispatch_async(dispatch_get_main_queue(), {
							self.fetchMemes(paging + 1)
						})
					}
					else {
						self.memes = self.fetchedMemes
						dispatch_async(dispatch_get_main_queue(), {
							SettingsManager.saveLastUpdateDate()
							NSNotificationCenter.defaultCenter().postNotificationName(kFetchCompleteNotification, object: nil, userInfo: ["memes": self.memes])
						})
						return
					}
				}
				catch _ {
					print("Unable to parse")
					return
				}
			}
			}.resume()
		
	}

}
