//
//  StopAndShapeQueryTests.swift
//

import Foundation
import Testing
@testable import SJ_Transit

@Suite struct StopAndShapeQueryTests {
    @Test func stops_fetch_and_lookup_roundtrip() throws {
        try TestDBSupport.ensureGTFSInstalled()

        let stops = Stop.stops()
        #expect(!stops.isEmpty)

        for s in stops.prefix(5) {
            #expect(s.stopId != nil)
            #expect(s.stopName != nil)
            #expect(s.latitude != nil)
            #expect(s.longitude != nil)

            if let sid = s.stopId, let fetched = Stop.stop(byId: sid) {
                #expect(fetched.stopId == s.stopId)
                #expect(fetched.stopName == s.stopName)
            } else {
                Issue.record("Failed to refetch stop by id: \(String(describing: s.stopId))")
            }
        }
    }
}

