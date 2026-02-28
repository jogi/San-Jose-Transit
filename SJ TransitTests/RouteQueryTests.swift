import Foundation
import Testing
@testable import SJ_Transit
import GTFSModel

@Suite struct RouteQueryTests {
    @Test func routes_fetch_and_lookup_roundtrip() throws {
        try TestDBSupport.ensureGTFSInstalled()

        let routes = Route.routes()
        #expect(!routes.isEmpty)

        for route in routes.prefix(5) {
            #expect(!route.identifier.isEmpty)
            #expect(route.longName != nil)

            if let fetched = Route.route(byId: route.identifier) {
                #expect(fetched.identifier == route.identifier)
                #expect(fetched.type == route.type)
                #expect(fetched.longName == route.longName)
            } else {
                Issue.record("Failed to refetch route by id: \(route.identifier)")
            }
        }
    }
}
