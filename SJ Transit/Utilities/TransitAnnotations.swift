import Foundation
import MapKit
import GTFSModel

final class StopAnnotation: NSObject, MKAnnotation {
    let stop: Stop

    init(stop: Stop) {
        self.stop = stop
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
    }

    var title: String? {
        stop.name
    }

    var subtitle: String? {
        stop.routes
    }
}

final class StopTimeAnnotation: NSObject, MKAnnotation {
    let stopTime: TripStopSummary

    init(stopTime: TripStopSummary) {
        self.stopTime = stopTime
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: stopTime.stopLatitude, longitude: stopTime.stopLongitude)
    }

    var title: String? {
        stopTime.stopName
    }

    var subtitle: String? {
        stopTime.arrivalTime.timeWithMeridianAsString
    }
}
