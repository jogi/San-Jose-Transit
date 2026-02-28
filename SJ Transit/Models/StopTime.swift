import Foundation
import GTFSModel

extension StopTime {
    static func routeSummaries(stopIdentifier: String, routeIdentifiers: [String], afterTime: Date) -> [StopRouteSummary] {
        TransitStore.routeSummaries(stopIdentifier: stopIdentifier, routeIdentifiers: routeIdentifiers, afterTime: afterTime)
    }

    static func routeStopTimes(stopIdentifier: String, routeIdentifier: String, afterTime: Date) -> [StopRouteSummary] {
        TransitStore.routeStopTimes(stopIdentifier: stopIdentifier, routeIdentifier: routeIdentifier, afterTime: afterTime)
    }

    static func tripStopTimes(tripIdentifier: String) -> [TripStopSummary] {
        TransitStore.tripStopTimes(tripIdentifier: tripIdentifier)
    }

    static func nextTripIdentifier(routeIdentifier: String, directionIdentifier: Int, afterTime: Date) -> String? {
        TransitStore.nextTripIdentifier(routeIdentifier: routeIdentifier, directionIdentifier: directionIdentifier, afterTime: afterTime)
    }
}
