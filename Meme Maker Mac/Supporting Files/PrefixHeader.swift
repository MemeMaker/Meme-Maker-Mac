//
//  PrefixHeader.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/23/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import Foundation

let API_BASE_URL: String = "http://alpha-meme-maker.herokuapp.com"

func apiMemesPaging(_ page: Int) -> URL {
	return URL(string: "\(API_BASE_URL)/\(page)/")!
}

func apiParticularMeme(_ memeID: Int) -> URL {
	return URL(string: "\(API_BASE_URL)/memes/\(memeID)/")!
}

func apiSubmissionsPaging(_ page: Int) -> URL {
	return URL(string: "\(API_BASE_URL)/submissions/\(page)/")!
}

func apiSubmissionsForMeme(_ memeID: Int) -> URL {
	return URL(string: "\(API_BASE_URL)/memes/\(memeID)/submissions/")!
}

func getDocumentsDirectory() -> String {
	let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

func imagesPathForFileName(_ name: String) -> String {
	let directoryPath = getDocumentsDirectory() + "/images/"
	let manager = FileManager.default
	if (!manager.fileExists(atPath: directoryPath)) {
		do {
			try manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath + "\(name).jpg"
}

func getImagesFolder() -> String {
	let directoryPath = getDocumentsDirectory() + "/images/"
	let manager = FileManager.default
	if (!manager.fileExists(atPath: directoryPath)) {
		do {
			try manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath
}

func userImagesPathForFileName(_ name: String) -> String {
	let directoryPath = getDocumentsDirectory() + "/userImages/"
	let manager = FileManager.default
	if (!manager.fileExists(atPath: directoryPath)) {
		do {
			try manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath + "\(name).jpg"
}

func documentsPathForFileName(_ name: String) -> String {
	let directoryPath = getDocumentsDirectory() + "/resources/"
	let manager = FileManager.default
	if (!manager.fileExists(atPath: directoryPath)) {
		do {
			try manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
		} catch _ { }
	}
	return directoryPath + "\(name).dat"
}

func saveLastImage(_ image: NSImage) -> Void {
	let bitmapImageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
	if let data = bitmapImageRep?.representation(using: .JPEG, properties: [NSImageCompressionFactor: NSNumber.init(value: 0.7 as Float)]) {
		try? data.write(to: URL(fileURLWithPath: userImagesPathForFileName("lastImage")), options: [.atomic])
	}
}

func getLastImage() -> NSImage? {
	if let image = NSImage(contentsOfFile: userImagesPathForFileName("lastImage")) {
		return image
	}
	return nil
}

