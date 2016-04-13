//
//  Constants.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/2/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation

// Database
let kGTFSDBPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0].stringByAppendingString("/gtfs.db")
let kFavoritesDBPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/favorites.sqlite3")

// Defaults
let kDefaultsFirstTimeKey = "kFirstTime"
let kDefaultsGTFSVersionKey = "kGTFSVersion"

// Notifications
let kDidFinishDownloadingSchedulesNotification = "kDidFinishDownloadingSchedulesNotification"