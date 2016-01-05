//
//  Database.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import Foundation
import SQLite

class Database {
    static var connection: Connection? {
        get {
            let path = NSBundle.mainBundle().pathForResource("vta_gtfs", ofType: "db")!
            
            var db = Connection!()
            do {
                db = try Connection(path, readonly: true)
            } catch {
                db = nil
            }
            
            return db
        }
    }
    
    
    static var favoritesConnection: Connection? {
        get {
            let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/favorites.db")
            
            var db = Connection!()
            do {
                db = try Connection(path)
            } catch {
                db = nil
            }
            
            return db
        }
    }
}


let SQLTimeFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(name: "PST")
    return formatter
}()