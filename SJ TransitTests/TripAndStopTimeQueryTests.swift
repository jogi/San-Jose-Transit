//
//  TripAndStopTimeQueryTests.swift
//

import Foundation
import Testing
@testable import SJ_Transit

@Suite struct TripAndStopTimeQueryTests {

    private func findActiveDate(for routeId: String, horizonDays: Int = 30) -> (date: Date, tripIds: [String])? {
        let cal = Calendar.current
        for offset in 0..<horizonDays {
            let date = cal.date(byAdding: .day, value: offset, to: Date())!
            let tripIds = Trip.trips([routeId], activeOn: date)
            if !tripIds.isEmpty {
                return (date, tripIds)
            }
        }
        return nil
    }

    @Test func trip_and_stop_times_queries_cover_paths() throws {
        try TestDBSupport.ensureGTFSInstalled()

        // Choose a route with active service soon
        let allRoutes = Route.routes()
        print("[Test] allRoutes.count=\(allRoutes.count)")
        if allRoutes.isEmpty {
            Issue.record("No routes available in GTFS DB")
            return
        }

        var picked: (routeId: String, activeDate: Date, tripIds: [String])?
        for route in allRoutes {
            if let rid = route.routeId, let found = findActiveDate(for: rid) {
                picked = (rid, found.date, found.tripIds)
                print("[Test] picked routeId=\(rid) tripIds.count=\(found.tripIds.count)")
                break
            }
        }
        if picked == nil {
            Issue.record("No active trips found in horizon for any route")
            return
        }
        let routeId = picked!.routeId
        let activeOn = picked!.activeDate
        let tripIds = picked!.tripIds
        
        // Validate multi-route Trip.trips union behavior against per-route results
        if let another = allRoutes.first(where: { $0.routeId != routeId })?.routeId {
            let tripsSingleA = Trip.trips([routeId], activeOn: activeOn)
            let tripsSingleB = Trip.trips([another], activeOn: activeOn)
            let tripsCombined = Trip.trips([routeId, another], activeOn: activeOn)
            // Combined must contain at least all from A and B
            #expect(Set(tripsSingleA).isSubset(of: Set(tripsCombined)))
            #expect(Set(tripsSingleB).isSubset(of: Set(tripsCombined)))
        }

        // 1) Trip.stopTimes(tripId)
        let sampleTripId = tripIds[0]
        print("[Test] sampleTripId=\(sampleTripId)")
        let tripStops = StopTime.stopTimes(sampleTripId)
        print("[Test] tripStops.count=\(tripStops.count)")
        #expect(!tripStops.isEmpty)
        #expect(tripStops.sorted { $0.stopSequence < $1.stopSequence }.first?.stopSequence == tripStops.first?.stopSequence)

        // Use start-of-day cutoff and pick a stop that yields future times
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(abbreviation: "PST")!

        let afterTime = cal.date(from: DateComponents(year: 2025, month: 8, day: 11, hour: 0, minute: 0, second: 1))!
        var stopId: String = tripStops.first!.stop.stopId!
        for s in tripStops {
            let candidate = s.stop.stopId!
            let probe = StopTime.stopTimes(candidate, routeId: routeId, tripIds: tripIds, afterTime: afterTime)
            if !probe.isEmpty {
                stopId = candidate
                break
            }
        }

        // 2) StopTime.stopTimes(stopId, routeId, tripIds, afterTime)
        let timesForStopAndRoute = StopTime.stopTimes(stopId, routeId: routeId, tripIds: tripIds, afterTime: afterTime)
        print("[Test] timesForStopAndRoute.count=\(timesForStopAndRoute.count) stopId=\(stopId) afterTime=\(DateFormatter.SQLTimeFormatter.string(from: afterTime))")
        #expect(!timesForStopAndRoute.isEmpty)
        for t in timesForStopAndRoute {
            #expect(t.arrivalTime != nil)
            #expect(t.trip.tripHeadsign != nil)
            #expect(t.trip.tripId != nil)
            #expect(t.trip.shapeId != nil)
            #expect(t.trip.directionId != nil)
        }

        // 3) StopTime.stopTimes(stopId, afterTime, tripIds) — grouped per route
        let timesForStopAnyRoute = StopTime.stopTimes(stopId, afterTime: afterTime, tripIds: tripIds)
        print("[Test] timesForStopAnyRoute.count=\(timesForStopAnyRoute.count)")
        #expect(!timesForStopAnyRoute.isEmpty)

        // 4) StopTime.trip(routeId, directionId, afterTime) — choose a seen direction
        let chosenDirection = timesForStopAndRoute.first!.trip.directionId!
        let nextTripId = StopTime.trip(routeId, directionId: chosenDirection, afterTime: afterTime)
        print("[Test] chosenDirection=\(chosenDirection) nextTripId=\(String(describing: nextTripId))")
        #expect(nextTripId != nil)

        // 5) Shapes for trip and for shape id
        if let shapeId = timesForStopAndRoute.first!.trip.shapeId {
            let byShape = Shape.shapes(forShape: shapeId)
            print("[Test] shapes.byShape.count=\(byShape.count) shapeId=\(shapeId)")
            #expect(!byShape.isEmpty)
        }
        let shapesByTrip = Shape.shapes(forTrip: sampleTripId)
        print("[Test] shapes.byTrip.count=\(shapesByTrip.count)")
        #expect(!shapesByTrip.isEmpty)
        // sequence should be ascending
        let ordered = shapesByTrip.map { $0.pointSequence! }
        #expect(ordered == ordered.sorted())

        // 6) Stop lookup ties back
        #expect(Stop.stop(byId: stopId) != nil)
    }
}
