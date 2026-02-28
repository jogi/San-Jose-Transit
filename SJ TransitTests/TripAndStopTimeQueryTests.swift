import Foundation
import Testing
@testable import SJ_Transit
import GTFSModel

@Suite struct TripAndStopTimeQueryTests {

    private func findActiveDate(for routeIdentifier: String) -> (date: Date, tripIds: [String])? {
        guard let range = TestDBSupport.calendarDateRange() else {
            return nil
        }
        let calendar = Foundation.Calendar.current
        let totalDays = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? 0
        guard totalDays >= 0 else {
            return nil
        }
        for offset in 0...totalDays {
            let date = calendar.date(byAdding: .day, value: offset, to: range.start)!
            let tripIds = Trip.trips([routeIdentifier], activeOn: date)
            if !tripIds.isEmpty {
                return (date, tripIds)
            }
        }
        return nil
    }

    @Test func trip_and_stop_times_queries_cover_paths() throws {
        try TestDBSupport.ensureGTFSInstalled()

        let allRoutes = Route.routes()
        if allRoutes.isEmpty {
            Issue.record("No routes available in GTFS DB")
            return
        }

        var picked: (routeIdentifier: String, activeDate: Date, tripIds: [String])?
        for route in allRoutes {
            if let found = findActiveDate(for: route.identifier) {
                picked = (route.identifier, found.date, found.tripIds)
                break
            }
        }
        if picked == nil {
            Issue.record("No active trips found in horizon for any route")
            return
        }
        let routeIdentifier = picked!.routeIdentifier
        let activeOn = picked!.activeDate
        let tripIds = picked!.tripIds
        
        if let another = allRoutes.first(where: { $0.identifier != routeIdentifier })?.identifier {
            let tripsSingleA = Trip.trips([routeIdentifier], activeOn: activeOn)
            let tripsSingleB = Trip.trips([another], activeOn: activeOn)
            let tripsCombined = Trip.trips([routeIdentifier, another], activeOn: activeOn)
            #expect(Set(tripsSingleA).isSubset(of: Set(tripsCombined)))
            #expect(Set(tripsSingleB).isSubset(of: Set(tripsCombined)))
        }

        let sampleTripId = tripIds[0]
        let tripStops = StopTime.tripStopTimes(tripIdentifier: sampleTripId)
        #expect(!tripStops.isEmpty)
        #expect(tripStops.map { $0.stopSequence } == tripStops.map { $0.stopSequence }.sorted())

        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "PST")!

        let startOfActiveDay = calendar.startOfDay(for: activeOn)
        let afterTime = calendar.date(byAdding: .second, value: 1, to: startOfActiveDay) ?? activeOn
        var stopIdentifier: String = tripStops.first!.stopIdentifier

        let routeIds = [routeIdentifier]
        for stop in tripStops {
            let probe = StopTime.routeSummaries(stopIdentifier: stop.stopIdentifier, routeIdentifiers: routeIds, afterTime: afterTime)
            if !probe.isEmpty {
                stopIdentifier = stop.stopIdentifier
                break
            }
        }

        let timesForStopAndRoute = StopTime.routeStopTimes(stopIdentifier: stopIdentifier, routeIdentifier: routeIdentifier, afterTime: afterTime)
        #expect(!timesForStopAndRoute.isEmpty)
        for time in timesForStopAndRoute {
            #expect(DateFormatter.SQLTimeFormatter.string(from: time.arrivalTime).isEmpty == false)
            #expect(time.tripHeadsign != nil)
            #expect(!time.tripIdentifier.isEmpty)
            #expect(time.shapeIdentifier != nil)
            #expect(time.directionIdentifier != nil)
        }

        let timesForStopAnyRoute = StopTime.routeSummaries(stopIdentifier: stopIdentifier, routeIdentifiers: routeIds, afterTime: afterTime)
        #expect(!timesForStopAnyRoute.isEmpty)

        let chosenDirection = timesForStopAndRoute.first!.directionIdentifier ?? 0
        let nextTripId = StopTime.nextTripIdentifier(routeIdentifier: routeIdentifier, directionIdentifier: chosenDirection, afterTime: afterTime)
        #expect(nextTripId != nil)

        if let shapeIdentifier = timesForStopAndRoute.first!.shapeIdentifier {
            let byShape = Shape.shapes(forShape: shapeIdentifier)
            #expect(!byShape.isEmpty)
        }
        let shapesByTrip = Shape.shapes(forTrip: sampleTripId)
        #expect(!shapesByTrip.isEmpty)

        let ordered = shapesByTrip.map { Int($0.sequence) }
        #expect(ordered == ordered.sorted())

        #expect(Stop.stop(byId: stopIdentifier) != nil)
    }
}
