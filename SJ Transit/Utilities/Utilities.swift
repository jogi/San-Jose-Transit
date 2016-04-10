//
//  Utilities.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/3/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation


class Utilities {
    class func isScheduleEmpty() -> Bool {
        var isEmpty: Bool = false
        let defaults = NSUserDefaults.standardUserDefaults()
        if NSFileManager.defaultManager().fileExistsAtPath(kGTFSDBPath) == false {
            defaults.setBool(true, forKey: kDefaultsFirstTimeKey)
            defaults.setInteger(0, forKey: kDefaultsGTFSVersionKey)
            defaults.synchronize()
            isEmpty = true
        }
        
        return isEmpty
    }
    
    
    class func deleteFileInDocumentsDirectory(file: String) {
        let fullPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/\(file)")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fullPath)
        } catch {
            print("Error deleting file at path: \(fullPath)")
        }
    }
    
    
    class func deleteFileInCachesDirectory(file: String) {
        let fullPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0].stringByAppendingString("/\(file)")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fullPath)
        } catch {
            print("Error deleting file at path: \(fullPath)")
        }
    }
    
    
    class func cleanupOldFiles() {
        // check to see if we just upgraded from an old version
        if let _ = NSUserDefaults.standardUserDefaults().stringForKey("vta_version") {
            let documentsFiles = ["favorites.db", "system_map.pdf"]
            let cachesFiles = ["maps", "system_map.pdf", "vta_gtfs.db"]
            
            documentsFiles.forEach { (aFile) in
                Utilities.deleteFileInDocumentsDirectory(aFile)
            }
            
            cachesFiles.forEach { (aFile) in
                Utilities.deleteFileInCachesDirectory(aFile)
            }
            
            let oldPreferences = ["first_time", "first_time_pref", "is_icloud_ready", "vta_version"]
            oldPreferences.forEach { (aPref) in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(aPref)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}