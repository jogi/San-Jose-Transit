import Foundation
import GTFSModel

extension GTFSModel.Calendar {
    static func isServiceActive(_ date: Date, serviceId serviceIdentifier: String) -> Bool {
        TransitStore.isServiceActive(on: date, serviceIdentifier: serviceIdentifier)
    }
}
