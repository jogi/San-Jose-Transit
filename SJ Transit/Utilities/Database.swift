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
    // Injection points (optional). When set, these override default constants.
    static var overrideGTFSDBPath: String?
    static var overrideFavoritesDBPath: String?

    // Configure paths for unit tests or alternate environments
    static func configure(gtfsPath: String? = nil, favoritesPath: String? = nil) {
        overrideGTFSDBPath = gtfsPath
        overrideFavoritesDBPath = favoritesPath
    }

    static var connection: Connection? {
        get {
            let path = overrideGTFSDBPath ?? kGTFSDBPath
            
            var db: Connection?
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
            let path = overrideFavoritesDBPath ?? kFavoritesDBPath
            
            var db: Connection?
            do {
                db = try Connection(path)
            } catch {
                db = nil
            }
            
            return db
        }
    }
}
