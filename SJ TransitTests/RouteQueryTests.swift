//
//  RouteQueryTests.swift
//

import Foundation
import Testing
@testable import SJ_Transit

@Suite struct RouteQueryTests {
    @Test func routes_fetch_and_lookup_roundtrip() throws {
        try TestDBSupport.ensureGTFSInstalled()

        let routes = Route.routes()
        #expect(!routes.isEmpty)

        // Validate basic fields and round-trip by id for a few samples
        for route in routes.prefix(5) {
            #expect(route.routeId != nil)
            #expect(route.routeLongName != nil)
            #expect(route.routeType != nil)

            if let rid = route.routeId, let fetched = Route.route(byId: rid) {
                #expect(fetched.routeId == route.routeId)
                #expect(fetched.routeType == route.routeType)
                #expect(fetched.routeLongName == route.routeLongName)
            } else {
                Issue.record("Failed to refetch route by id: \(String(describing: route.routeId))")
            }
        }
    }
}

