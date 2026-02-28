import GTFSModel

extension Route {
    static func routes() -> [Route] {
        TransitStore.routes()
    }

    static func route(byId routeIdentifier: String) -> Route? {
        TransitStore.route(identifier: routeIdentifier)
    }
}
