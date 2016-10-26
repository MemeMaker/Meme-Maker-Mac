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
	
	var imageURL: URL?
	
	class func createOrUpdateMemeWithData(_ data: NSDictionary, context: NSManagedObjectContext) -> XMeme {
		
		let ID: Int = ((data.object(forKey: "ID") as AnyObject).intValue)!
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "XMeme")
		fetchRequest.predicate = NSPredicate(format: "memeID == %li", ID)
		
		var meme: XMeme!
		
		do {
			let fetchedArray = try context.fetch(fetchRequest)
			if (fetchedArray.count > 0) {
//				print("Meme \(ID) already present.")
				meme = fetchedArray.first as! XMeme
			}
			else {
//				print("Inserting meme \(ID).")
				meme = NSEntityDescription.insertNewObject(forEntityName: "XMeme", into: context) as! XMeme
				meme.memeID = ((data.object(forKey: "ID")? as AnyObject).int32Value)!
			}
		}
		catch _ {
			
		}

		meme.name = data.object(forKey: "name") as? String
		meme.topText = data.object(forKey: "topText") as? String
		meme.bottomText = data.object(forKey: "bottomText") as? String
		meme.tags = data.object(forKey: "tags") as? String
		meme.detail = data.object(forKey: "detail") as? String
		meme.image = data.object(forKey: "image") as? String
		meme.imageURL = URL(string: meme.image!)
		meme.thumb = data.object(forKey: "thumb") as? String
		meme.rank = ((data.object(forKey: "rank")? as AnyObject).int32Value)!
	
		return meme
		
	}
	
	class func getAllMemesFromArray(_ array: NSArray, context: NSManagedObjectContext) -> NSArray? {
		
		let memesArray: NSMutableArray = NSMutableArray()
		
		for dict in array {
			
			let meme = self.createOrUpdateMemeWithData(dict as! NSDictionary, context: context)
			memesArray.add(meme)
			
		}
		
		return memesArray
		
	}
	
	override var description: String {
		return "XMeme\t| \(self.memeID)\t| \(self.name!)"
	}

}
