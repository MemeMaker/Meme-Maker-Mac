//
//  XMeme.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/4/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Foundation
import CoreData

class XMeme: NSManagedObject {
	
	var imageURL: NSURL?
	
	class func createOrUpdateMemeWithData(data: NSDictionary, context: NSManagedObjectContext) -> XMeme {
		
		let ID: Int = (data.objectForKey("ID")?.integerValue)!
		
		let fetchRequest = NSFetchRequest(entityName: "XMeme")
		fetchRequest.predicate = NSPredicate(format: "memeID == %li", ID)
		
		var meme: XMeme!
		
		do {
			let fetchedArray = try context.executeFetchRequest(fetchRequest)
			if (fetchedArray.count > 0) {
//				print("Meme \(ID) already present.")
				meme = fetchedArray.first as! XMeme
			}
			else {
//				print("Inserting meme \(ID).")
				meme = NSEntityDescription.insertNewObjectForEntityForName("XMeme", inManagedObjectContext: context) as! XMeme
				meme.memeID = (data.objectForKey("ID")?.intValue)!
			}
		}
		catch _ {
			
		}

		meme.name = data.objectForKey("name") as? String
		meme.topText = data.objectForKey("topText") as? String
		meme.bottomText = data.objectForKey("bottomText") as? String
		meme.tags = data.objectForKey("tags") as? String
		meme.detail = data.objectForKey("detail") as? String
		meme.image = data.objectForKey("image") as? String
		meme.imageURL = NSURL(string: meme.image!)
		meme.thumb = data.objectForKey("thumb") as? String
		meme.rank = (data.objectForKey("rank")?.intValue)!
	
		return meme
		
	}
	
	class func getAllMemesFromArray(array: NSArray, context: NSManagedObjectContext) -> NSArray? {
		
		let memesArray: NSMutableArray = NSMutableArray()
		
		for dict in array {
			
			let meme = self.createOrUpdateMemeWithData(dict as! NSDictionary, context: context)
			memesArray.addObject(meme)
			
		}
		
		return memesArray
		
	}
	
	override var description: String {
		return "XMeme\t| \(self.memeID)\t| \(self.name!)"
	}

}
