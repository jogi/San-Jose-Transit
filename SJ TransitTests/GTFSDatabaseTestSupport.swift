//
//  GTFSDatabaseTestSupport.swift
//  SJ TransitTests
//
//  Helpers to install gtfs.db into the app caches directory and reset favorites DB.
//

import Foundation
import Testing
@testable import SJ_Transit
import SQLite

final class _TestBundleToken {}

enum TestDBSupport {
    private static var installed = false

    static func ensureGTFSInstalled() throws {
        guard !installed else { return }

        // Resolve gtfs.db from the unit test bundle resources
        let bundle = Bundle(for: _TestBundleToken.self)
        guard let srcURL = bundle.url(forResource: "gtfs", withExtension: "db") ??
                Bundle.main.url(forResource: "gtfs", withExtension: "db") else {
            Issue.record("gtfs.db not found in test or main bundle resources")
            return
        }

        // Provide explicit paths to the app Database for tests
        let tmpDir = NSTemporaryDirectory() as NSString
        let favsPath = tmpDir.appendingPathComponent("test-favorites.sqlite3")
        // Set injectable paths
        Database.configure(gtfsPath: srcURL.path, favoritesPath: favsPath)

        // Debug info to confirm file visibility in simulator
        let exists = FileManager.default.fileExists(atPath: srcURL.path)
        print("[TestDBSupport] Using GTFS at: \(srcURL.path) exists=\(exists)")
        print("[TestDBSupport] Favorites at: \(favsPath)")

        // Quick smoke: try opening and counting routes
        if let db = Database.connection {
            do {
                let tbl = Table("routes")
                let count = try db.scalar(tbl.count)
                print("[TestDBSupport] routes count=\(count)")
            } catch {
                Issue.record("Unable to query routes count: \(error)")
            }
        } else {
            Issue.record("Database.connection is nil for path: \(String(describing: Database.overrideGTFSDBPath))")
        }

        // Ensure a clean favorites file
        resetFavoritesDB()

        // Minimal diagnostics for visibility in CI logs
        diagnoseDatabase()

        installed = true
    }

    static func resetFavoritesDB() {
        // Remove the configured favorites DB if present
        let path = Database.overrideFavoritesDBPath ?? {
            let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return (docsDir as NSString).appendingPathComponent("favorites.sqlite3")
        }()
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            try? fm.removeItem(atPath: path)
        }
        Favorite.createFavoritesIfRequred()
    }
}

// MARK: - Diagnostics
func diagnoseDatabase() {
    guard let db = Database.connection else {
        print("[Diag] Database.connection is nil at path: \(String(describing: Database.overrideGTFSDBPath))")
        return
    }
    do {
        let routes = Table("routes")
        let stops = Table("stops")
        let trips = Table("trips")
        let stopTimes = Table("stop_times")
        let calendar = Table("calendar")

        let rc = try db.scalar(routes.count)
        let sc = try db.scalar(stops.count)
        let tc = try db.scalar(trips.count)
        let stc = try db.scalar(stopTimes.count)
        let cc = try db.scalar(calendar.count)
        print("[Diag] counts routes=\(rc) stops=\(sc) trips=\(tc) stop_times=\(stc) calendar=\(cc)")
    } catch {
        print("[Diag] Counting tables failed: \(error)")
    }
}
