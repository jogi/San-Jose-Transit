import CoreLocation
import GTFSModel

extension Shape {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func shapes(forShape shapeIdentifier: String) -> [Shape] {
        TransitStore.shapes(shapeIdentifier: shapeIdentifier)
    }

    static func shapes(forTrip tripIdentifier: String) -> [Shape] {
        TransitStore.shapes(tripIdentifier: tripIdentifier)
    }
}
