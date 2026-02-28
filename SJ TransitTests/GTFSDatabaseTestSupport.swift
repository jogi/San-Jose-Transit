//
//  GTFSDatabaseTestSupport.swift
//  SJ TransitTests
//

import Foundation
import Testing
@testable import SJ_Transit
import GRDB

final class _TestBundleToken {}

enum TestDBSupport {
    private static var installed = false

    static func ensureGTFSInstalled() throws {
        guard !installed else { return }

        let bundle = Bundle(for: _TestBundleToken.self)
        guard let srcURL = bundle.url(forResource: "gtfs", withExtension: "db") ??
                Bundle.main.url(forResource: "gtfs", withExtension: "db") else {
            Issue.record("gtfs.db not found in test or main bundle resources")
            return
        }

        let tmpDir = NSTemporaryDirectory() as NSString
        let favsPath = tmpDir.appendingPathComponent("test-favorites.sqlite3")
        Database.configure(gtfsPath: srcURL.path, favoritesPath: favsPath)

        let exists = FileManager.default.fileExists(atPath: srcURL.path)
        print("[TestDBSupport] Using GTFS at: \(srcURL.path) exists=\(exists)")
        print("[TestDBSupport] Favorites at: \(favsPath)")

        if let dbQueue = Database.connection {
            do {
                let count = try dbQueue.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM routes") ?? 0
                }
                print("[TestDBSupport] routes count=\(count)")
            } catch {
                Issue.record("Unable to query routes count: \(error)")
            }
        } else {
            Issue.record("Database.connection is nil for path: \(String(describing: Database.overrideGTFSDBPath))")
        }

        resetFavoritesDB()
        diagnoseDatabase()

        installed = true
    }

    static func resetFavoritesDB() {
        let path = Database.overrideFavoritesDBPath ?? {
            let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return (docsDir as NSString).appendingPathComponent("favorites.sqlite3")
        }()
        let gtfsPath = Database.overrideGTFSDBPath
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            try? fm.removeItem(atPath: path)
        }
        Database.configure(gtfsPath: gtfsPath, favoritesPath: path)
        Favorite.createFavoritesIfRequred()
    }

    static func calendarDateRange() -> (start: Date, end: Date)? {
        guard let dbQueue = Database.connection else {
            return nil
        }

        do {
            return try dbQueue.read { db in
                guard let row = try Row.fetchOne(
                    db,
                    sql: "SELECT MIN(start_date) AS min_start, MAX(end_date) AS max_end FROM calendar"
                ) else {
                    return nil
                }
                guard let minStart = row["min_start"] as String?,
                      let maxEnd = row["max_end"] as String?,
                      let startDate = DateFormatter.PSTDateFormatterDate.date(from: minStart),
                      let endDate = DateFormatter.PSTDateFormatterDate.date(from: maxEnd) else {
                    return nil
                }
                return (startDate, endDate)
            }
        } catch {
            return nil
        }
    }
}

func diagnoseDatabase() {
    guard let dbQueue = Database.connection else {
        print("[Diag] Database.connection is nil at path: \(String(describing: Database.overrideGTFSDBPath))")
        return
    }
    do {
        let counts = try dbQueue.read { db in
            let routes = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM routes") ?? 0
            let stops = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM stops") ?? 0
            let trips = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM trips") ?? 0
            let stopTimes = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM stop_times") ?? 0
            let calendar = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM calendar") ?? 0
            return (routes, stops, trips, stopTimes, calendar)
        }
        print("[Diag] counts routes=\(counts.0) stops=\(counts.1) trips=\(counts.2) stop_times=\(counts.3) calendar=\(counts.4)")
    } catch {
        print("[Diag] Counting tables failed: \(error)")
    }
}
