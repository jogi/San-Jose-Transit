//
//  CalendarQueryTests.swift
//

import Foundation
import Testing
@testable import SJ_Transit
import SQLite

@Suite struct CalendarQueryTests {
    // Helper: fetch a service_id for a given trip
    private func serviceId(forTripId tripId: String) -> String? {
        guard let db = Database.connection else { return nil }
        let trips = Table("trips")
        let colTripId = Expression<String>("trip_id")
        let colServiceId = Expression<String>("service_id")
        do {
            for row in try db.prepare(trips.select(colServiceId).filter(colTripId == tripId).limit(1)) {
                return row[colServiceId]
            }
        } catch {
            Issue.record("Query trips failed: \(error)")
        }
        return nil
    }

    // Helper: fetch calendar row window for service
    private func calendarWindow(forService serviceId: String) -> (start: String, end: String, weekdays: [String:Int])? {
        guard let db = Database.connection else { return nil }
        let calendar = Table("calendar")
        let colServiceId = Expression<String>("service_id")
        let colStartDate = Expression<String>("start_date")
        let colEndDate = Expression<String>("end_date")
        let cols = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
        var result: (String, String, [String:Int])?
        do {
            for row in try db.prepare(calendar.filter(colServiceId == serviceId).limit(1)) {
                var weekdays: [String:Int] = [:]
                for c in cols { weekdays[c] = row[Expression<Int>(c)] }
                result = (row[colStartDate], row[colEndDate], weekdays)
            }
        } catch {
            Issue.record("Query calendar failed: \(error)")
        }
        return result
    }

    @Test func calendar_isServiceActive_true_and_false_cases() throws {
        try TestDBSupport.ensureGTFSInstalled()

        // Find a route/date/trip to anchor a service id
        guard let routeId = Route.routes().first?.routeId else {
            Issue.record("No routes to inspect")
            return
        }
        // Search forward for a day with trips
        var found: (date: Date, tripIds: [String])?
        let cal = Calendar.current
        for offset in 0..<30 {
            let date = cal.date(byAdding: .day, value: offset, to: Date())!
            let trips = Trip.trips([routeId], activeOn: date)
            if !trips.isEmpty { found = (date, trips); break }
        }
        if found == nil {
            Issue.record("No active trips found within horizon")
            return
        }
        guard let sampleTrip = found!.tripIds.first, let svc = serviceId(forTripId: sampleTrip) else {
            Issue.record("Unable to resolve service id for a trip")
            return
        }

        // Expect true on the discovered active date
        #expect(Calendar.isServiceActive(found!.date, serviceId: svc))

        // Expect false outside the service window (one day before start)
        if let window = calendarWindow(forService: svc) {
            let formatter = Foundation.DateFormatter()
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            if let start = formatter.date(from: window.start) {
                let beforeStart = Calendar.current.date(byAdding: .day, value: -1, to: start)!
                #expect(!Calendar.isServiceActive(beforeStart, serviceId: svc))
            }
        }
    }
}
