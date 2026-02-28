import Foundation
import Testing
@testable import SJ_Transit
import GTFSModel
import GRDB

@Suite struct CalendarQueryTests {
    private func serviceIdentifier(forTripId tripIdentifier: String) -> String? {
        guard let dbQueue = Database.connection else { return nil }
        do {
            return try dbQueue.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT service_id FROM trips WHERE trip_id = ? LIMIT 1",
                    arguments: [tripIdentifier]
                )
            }
        } catch {
            Issue.record("Query trips failed: \(error)")
            return nil
        }
    }

    private func calendarWindow(forService serviceIdentifier: String) -> (start: String, end: String, weekdays: [String: Int])? {
        guard let dbQueue = Database.connection else { return nil }
        do {
            return try dbQueue.read { db in
                guard let row = try Row.fetchOne(db, sql: "SELECT * FROM calendar WHERE service_id = ? LIMIT 1", arguments: [serviceIdentifier]) else {
                    return nil
                }
                let columns = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
                var weekdays: [String: Int] = [:]
                for column in columns {
                    weekdays[column] = Int((row[column] as Int64?) ?? 0)
                }
                return (
                    row["start_date"] as String? ?? "",
                    row["end_date"] as String? ?? "",
                    weekdays
                )
            }
        } catch {
            Issue.record("Query calendar failed: \(error)")
            return nil
        }
    }

    @Test func calendar_isServiceActive_true_and_false_cases() throws {
        try TestDBSupport.ensureGTFSInstalled()

        guard let routeIdentifier = Route.routes().first?.identifier else {
            Issue.record("No routes to inspect")
            return
        }

        guard let range = TestDBSupport.calendarDateRange() else {
            Issue.record("Unable to determine calendar date range from GTFS DB")
            return
        }

        var found: (date: Date, tripIds: [String])?
        let calendar = Foundation.Calendar.current
        let totalDays = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? 0
        guard totalDays >= 0 else {
            Issue.record("Invalid calendar range")
            return
        }
        for offset in 0...totalDays {
            let date = calendar.date(byAdding: .day, value: offset, to: range.start)!
            let trips = Trip.trips([routeIdentifier], activeOn: date)
            if !trips.isEmpty {
                found = (date, trips)
                break
            }
        }
        if found == nil {
            Issue.record("No active trips found within horizon")
            return
        }

        guard let sampleTrip = found!.tripIds.first,
              let serviceIdentifier = serviceIdentifier(forTripId: sampleTrip) else {
            Issue.record("Unable to resolve service id for a trip")
            return
        }

        #expect(GTFSModel.Calendar.isServiceActive(found!.date, serviceId: serviceIdentifier))

        if let window = calendarWindow(forService: serviceIdentifier) {
            let formatter = Foundation.DateFormatter()
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            if let start = formatter.date(from: window.start) {
                let beforeStart = Foundation.Calendar.current.date(byAdding: .day, value: -1, to: start)!
                #expect(!GTFSModel.Calendar.isServiceActive(beforeStart, serviceId: serviceIdentifier))
            }
        }
    }
}
