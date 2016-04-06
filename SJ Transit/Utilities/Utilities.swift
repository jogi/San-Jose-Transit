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
}