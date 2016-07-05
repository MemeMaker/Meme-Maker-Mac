//
//  AppDelegate.swift
//  Meme Maker Mac
//
//  Created by Avikant Saini on 5/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

let kToggleViewModeNotification: String = "kToggleViewModeNotification"
let kToggleViewModeKey: String = "kToggleViewModeKey"

let kResetPositionNotification: String = "kResetPositionNotification"
let kResetAllNotification: String = "kResetAllNotification"

let kFontBiggerNotification: String = "kFontBiggerNotification"
let kFontSmallerNotification: String = "kFontSmallerNotification"

let kAlignTextNotification: String = "kAlignTextNotification"

let kFillDefaultTextNotification: String = "kFillDefaultTextNotification"

let kTextColorPanelNotification: String = "kTextColorPanelNotification"
let kOutlineColorPanelNotification: String = "kOutlineColorPanelNotification"

let kUpdateAttributesNotification: String = "kUpdateAttributesNotification"
let kTopAttrName: String = "topAttr"
let kBottomAttrName: String = "bottomAttr"

import Cocoa
import SSZipArchive

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		
		let timesLaunched = SettingsManager.getInteger(kSettingsTimesLaunched)
		if (timesLaunched == 0) {
			SettingsManager.setBool(false, key: kSettingsAutoDismiss)
			SettingsManager.setBool(false, key: kSettingsResetSettingsOnLaunch)
			SettingsManager.setBool(true, key: kSettingsContinuousEditing)
			SettingsManager.setBool(false, key: kSettingsUploadMemes)
			SettingsManager.setInteger(3, key: kSettingsNumberOfElementsInGrid)
			SettingsManager.setObject("rank", key: kSettingsLastSortKey)
			print("Unarchiving to \(getImagesFolder())")
			SSZipArchive.unzipFileAtPath(NSBundle.mainBundle().pathForResource("defaultMemes", ofType: "zip"), toDestination: getImagesFolder())
			saveDefaultMemes()
		}
		SettingsManager.setInteger(timesLaunched + 1, key: kSettingsTimesLaunched)
		if SettingsManager.getBool(kSettingsResetSettingsOnLaunch) {
			XTextAttributes.clearTopAndBottomTexts()
		}
		if (SettingsManager.getInteger(kSettingsNumberOfElementsInGrid) < 3 || SettingsManager.getInteger(kSettingsNumberOfElementsInGrid) > 7) {
			SettingsManager.setInteger(3, key: kSettingsNumberOfElementsInGrid)
		}
		if ("rank memeID name".containsString(SettingsManager.getObject(kSettingsLastSortKey) as! String)) {
			SettingsManager.setObject("rank", key: kSettingsLastSortKey)
		}
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
	// MARK: - Application menu actions
	
	@IBAction func newMenuAction(sender: AnyObject) {
	}
	
	@IBAction func saveMenuAction(sender: AnyObject) {
	}
	
	@IBAction func openMenuAction(sender: AnyObject) {
	}
	
	@IBAction func resetMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kResetPositionNotification, object: nil)
	}
	
	@IBAction func resetAllMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kResetAllNotification, object: nil)
	}
	
	@IBAction func biggerMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kFontBiggerNotification, object: nil)
	}
	
	@IBAction func smallerMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kFontSmallerNotification, object: nil)
	}
	
	@IBAction func alignTextLeftMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kAlignTextNotification, object: nil, userInfo: ["alignment": NSNumber.init(int: 0)])
	}
	
	@IBAction func alignTextCenterMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kAlignTextNotification, object: nil, userInfo: ["alignment": NSNumber.init(int: 1)])
	}
	
	@IBAction func alignTextRightMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kAlignTextNotification, object: nil, userInfo: ["alignment": NSNumber.init(int: 2)])
	}
	
	@IBAction func alignTextJustifyMenuAction(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(kAlignTextNotification, object: nil, userInfo: ["alignment": NSNumber.init(int: 3)])
	}
	
	@IBAction func showFontsMenuAction(sender: AnyObject) {
		let topTextAttr: XTextAttributes =  XTextAttributes(savename: kTopAttrName)
		NSFontPanel.sharedFontPanel().setPanelFont(topTextAttr.font, isMultiple: false)
		NSFontPanel.sharedFontPanel().orderFront(sender)
	}
	
	@IBAction func fillDefaultTextMenuAction(sender: NSMenuItem) {
		let tag = sender.tag
		NSNotificationCenter.defaultCenter().postNotificationName(kFillDefaultTextNotification, object: nil, userInfo: ["topbottom": NSNumber.init(long: tag)])
	}
	
	
	// MARK: - Utility
	
	func saveDefaultMemes() -> Void {
		let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("defaultMemes", ofType: "dat")!)
		if (data != nil) {
			do {
				let jsonmemes = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
				let _ = XMeme.getAllMemesFromArray(jsonmemes as! NSArray, context: managedObjectContext)!
				try managedObjectContext.save()
			}
			catch _ {
				print("Unable to parse")
				return
			}
		}
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.avikantz.Meme_Maker_Mac" in the user's Application Support directory.
	    let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
	    let appSupportURL = urls[urls.count - 1]
	    return appSupportURL.URLByAppendingPathComponent("com.avikantz.Meme_Maker_Mac")
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = NSBundle.mainBundle().URLForResource("Meme_Maker_Mac", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
	    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    let fileSettingsManager = NSFileManager.defaultManager()
	    var failError: NSError? = nil
	    var shouldFail = false
	    var failureReason = "There was an error creating or loading the application's saved data."

	    // Make sure the application files directory is there
	    do {
	        let properties = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
	        if !properties[NSURLIsDirectoryKey]!.boolValue {
	            failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
	            shouldFail = true
	        }
	    } catch  {
	        let nserror = error as NSError
	        if nserror.code == NSFileReadNoSuchFileError {
	            do {
	                try fileSettingsManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
	            } catch {
	                failError = nserror
	            }
	        } else {
	            failError = nserror
	        }
	    }
	    
	    // Create the coordinator and store
	    var coordinator: NSPersistentStoreCoordinator? = nil
	    if failError == nil {
	        coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CocoaAppCD.storedata")
	        do {
	            try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
	        } catch {
	            failError = error as NSError
	        }
	    }
	    
	    if shouldFail || (failError != nil) {
	        // Report any error we got.
	        var dict = [String: AnyObject]()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason
	        if failError != nil {
	            dict[NSUnderlyingErrorKey] = failError
	        }
	        let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        NSApplication.sharedApplication().presentError(error)
	        abort()
	    } else {
	        return coordinator!
	    }
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
	    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
	    let coordinator = self.persistentStoreCoordinator
	    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
	    managedObjectContext.persistentStoreCoordinator = coordinator
	    return managedObjectContext
	}()

	// MARK: - Core Data Saving and Undo support

	@IBAction func saveAction(sender: AnyObject!) {
	    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
	    if !managedObjectContext.commitEditing() {
	        NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
	    }
	    if managedObjectContext.hasChanges {
	        do {
	            try managedObjectContext.save()
	        } catch {
	            let nserror = error as NSError
	            NSApplication.sharedApplication().presentError(nserror)
	        }
	    }
	}

	func windowWillReturnUndoSettingsManager(window: NSWindow) -> NSUndoManager? {
	    // Returns the NSUndoSettingsManager for the application. In this case, the SettingsManager returned is that of the managed object context for the application.
	    return managedObjectContext.undoManager
	}

	func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
	    // Save changes in the application's managed object context before the application terminates.
	    
	    if !managedObjectContext.commitEditing() {
	        NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
	        return .TerminateCancel
	    }
	    
	    if !managedObjectContext.hasChanges {
	        return .TerminateNow
	    }
	    
	    do {
	        try managedObjectContext.save()
	    } catch {
	        let nserror = error as NSError
	        // Customize this code block to include application-specific recovery steps.
	        let result = sender.presentError(nserror)
	        if (result) {
	            return .TerminateCancel
	        }
	        
	        let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
	        let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
	        let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
	        let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
	        let alert = NSAlert()
	        alert.messageText = question
	        alert.informativeText = info
	        alert.addButtonWithTitle(quitButton)
	        alert.addButtonWithTitle(cancelButton)
	        
	        let answer = alert.runModal()
	        if answer == NSAlertFirstButtonReturn {
	            return .TerminateCancel
	        }
	    }
	    // If we got here, it is time to quit.
	    return .TerminateNow
	}

}

