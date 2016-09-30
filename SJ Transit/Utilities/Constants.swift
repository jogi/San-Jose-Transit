//
//  Constants.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/2/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation

// Database
let kGTFSDBPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/gtfs.db"
let kFavoritesDBPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/favorites.sqlite3"

// Defaults
let kDefaultsFirstTimeKey = "kFirstTime"
let kDefaultsGTFSVersionKey = "kGTFSVersion"

// Notifications
let kDidFinishDownloadingSchedulesNotification = "kDidFinishDownloadingSchedulesNotification"
