import GTFSModel

extension Stop {
    static func stops() -> [Stop] {
        TransitStore.stops()
    }

    static func stop(byId stopIdentifier: String) -> Stop? {
        TransitStore.stop(identifier: stopIdentifier)
    }
}
