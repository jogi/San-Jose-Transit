//
//  Database.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import Foundation
import GRDB

class Database {
    // Injection points (optional). When set, these override default constants.
    static var overrideGTFSDBPath: String?
    static var overrideFavoritesDBPath: String?
    
    private static var gtfsQueueCache: DatabaseQueue?
    private static var gtfsPathCache: String?
    private static var favoritesQueueCache: DatabaseQueue?
    private static var favoritesPathCache: String?
    private static var hasPreparedGTFSIndexes = false

    // Configure paths for unit tests or alternate environments
    static func configure(gtfsPath: String? = nil, favoritesPath: String? = nil) {
        overrideGTFSDBPath = gtfsPath
        overrideFavoritesDBPath = favoritesPath
        gtfsQueueCache = nil
        gtfsPathCache = nil
        favoritesQueueCache = nil
        favoritesPathCache = nil
        hasPreparedGTFSIndexes = false
    }

    static var connection: DatabaseQueue? {
        get {
            let path = overrideGTFSDBPath ?? kGTFSDBPath
            if gtfsQueueCache == nil || gtfsPathCache != path {
                do {
                    var configuration = Configuration()
                    configuration.readonly = false
                    configuration.foreignKeysEnabled = true
                    gtfsQueueCache = try DatabaseQueue(path: path, configuration: configuration)
                    gtfsPathCache = path
                } catch {
                    gtfsQueueCache = nil
                    gtfsPathCache = nil
                }
            }
            prepareGTFSIndexesIfNeeded()
            return gtfsQueueCache
        }
    }
    
    
    static var favoritesConnection: DatabaseQueue? {
        get {
            let path = overrideFavoritesDBPath ?? kFavoritesDBPath
            if favoritesQueueCache == nil || favoritesPathCache != path {
                do {
                    var configuration = Configuration()
                    configuration.foreignKeysEnabled = true
                    favoritesQueueCache = try DatabaseQueue(path: path, configuration: configuration)
                    favoritesPathCache = path
                } catch {
                    favoritesQueueCache = nil
                    favoritesPathCache = nil
                }
            }
            return favoritesQueueCache
        }
    }
    
    private static func prepareGTFSIndexesIfNeeded() {
        guard hasPreparedGTFSIndexes == false else {
            return
        }
        guard let dbQueue = gtfsQueueCache else {
            return
        }
        
        do {
            try dbQueue.write { db in
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_trips_route_direction_service ON trips(route_id, direction_id, service_id)")
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_trips_trip ON trips(trip_id)")
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_stop_times_stop_time_trip ON stop_times(stop_id, arrival_time, trip_id)")
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_stop_times_trip_sequence ON stop_times(trip_id, stop_sequence)")
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_shapes_shape_sequence ON shapes(shape_id, shape_pt_sequence)")
                try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_calendar_service_window ON calendar(service_id, start_date, end_date)")
            }
            hasPreparedGTFSIndexes = true
        } catch {
            // Index creation is a best-effort optimization and should never block app reads.
            hasPreparedGTFSIndexes = true
        }
    }
}
