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
        let defaults = UserDefaults.standard
        if FileManager.default.fileExists(atPath: kGTFSDBPath) == false {
            defaults.set(true, forKey: kDefaultsFirstTimeKey)
            defaults.set(0, forKey: kDefaultsGTFSVersionKey)
            defaults.synchronize()
            isEmpty = true
        }
        
        return isEmpty
    }
    
    
    class func deleteFileInDocumentsDirectory(_ file: String) {
        let fullPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(file)"
        do {
            try FileManager.default.removeItem(atPath: fullPath)
        } catch {
            print("Error deleting file at path: \(fullPath)")
        }
    }
    
    
    class func deleteFileInCachesDirectory(_ file: String) {
        let fullPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/\(file)"
        do {
            try FileManager.default.removeItem(atPath: fullPath)
        } catch {
            print("Error deleting file at path: \(fullPath)")
        }
    }
    
    
    class func cleanupOldFiles() {
        // check to see if we just upgraded from an old version
        if let _ = UserDefaults.standard.string(forKey: "vta_version") {
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
                UserDefaults.standard.removeObject(forKey: aPref)
            }
            UserDefaults.standard.synchronize()
        }
    }
}
