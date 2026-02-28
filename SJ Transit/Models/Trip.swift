import Foundation
import GTFSModel

extension Trip {
    static func trips(_ routeIdentifiers: [String], activeOn date: Date) -> [String] {
        TransitStore.tripIdentifiers(routeIdentifiers: routeIdentifiers, activeOn: date)
    }

    static func trips(_ routeIdentifiers: [String], directionIdentifier: Int, activeOn date: Date) -> [String] {
        TransitStore.tripIdentifiers(routeIdentifiers: routeIdentifiers, activeOn: date, directionIdentifier: directionIdentifier)
    }
}
