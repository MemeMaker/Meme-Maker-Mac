//
//  PrefixHeader.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/23/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Foundation

let API_BASE_URL: String = "http://alpha-meme-maker.herokuapp.com"

func apiMemesPaging(page: Int) -> NSURL {
	return NSURL(string: "\(API_BASE_URL)/\(page)/")!
}

func apiParticularMeme(memeID: Int) -> NSURL {
	return NSURL(string: "\(API_BASE_URL)/memes/\(memeID)/")!
}

func apiSubmissionsPaging(page: Int) -> NSURL {
	return NSURL(string: "\(API_BASE_URL)/submissions/\(page)/")!
}

func apiSubmissionsForMeme(memeID: Int) -> NSURL {
	return NSURL(string: "\(API_BASE_URL)/memes/\(memeID)/submissions/")!
}

func getDocumentsDirectory() -> String {
	let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

func imagesPathForFileName(name: String) -> String {
	let directoryPath = getDocumentsDirectory().stringByAppendingString("/images/")
	let manager = NSFileManager.defaultManager()
	if (!manager.fileExistsAtPath(directoryPath)) {
		do {
			try manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath.stringByAppendingString("\(name).jpg")
}

func getImagesFolder() -> String {
	let directoryPath = getDocumentsDirectory().stringByAppendingString("/images/")
	let manager = NSFileManager.defaultManager()
	if (!manager.fileExistsAtPath(directoryPath)) {
		do {
			try manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath
}

func userImagesPathForFileName(name: String) -> String {
	let directoryPath = getDocumentsDirectory().stringByAppendingString("/userImages/")
	let manager = NSFileManager.defaultManager()
	if (!manager.fileExistsAtPath(directoryPath)) {
		do {
			try manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath.stringByAppendingString("\(name).jpg")
}

func documentsPathForFileName(name: String) -> String {
	let directoryPath = getDocumentsDirectory().stringByAppendingString("/resources/")
	let manager = NSFileManager.defaultManager()
	if (!manager.fileExistsAtPath(directoryPath)) {
		do {
			try manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath.stringByAppendingString("\(name).dat")
}

func saveLastImage(image: NSImage) -> Void {
	let bitmapImageRep = NSBitmapImageRep(data: image.TIFFRepresentation!)
	if let data = bitmapImageRep?.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: NSNumber.init(float: 0.7)]) {
		data.writeToFile(userImagesPathForFileName("lastImage"), atomically: true)
	}
}

func getLastImage() -> NSImage? {
	if let image = NSImage(contentsOfFile: userImagesPathForFileName("lastImage")) {
		return image
	}
	return nil
}

