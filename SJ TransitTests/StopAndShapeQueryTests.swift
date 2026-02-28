import Foundation
import Testing
@testable import SJ_Transit
import GTFSModel

@Suite struct StopAndShapeQueryTests {
    @Test func stops_fetch_and_lookup_roundtrip() throws {
        try TestDBSupport.ensureGTFSInstalled()

        let stops = Stop.stops()
        #expect(!stops.isEmpty)

        for stop in stops.prefix(5) {
            #expect(!stop.identifier.isEmpty)
            #expect(stop.name != nil)

            if let fetched = Stop.stop(byId: stop.identifier) {
                #expect(fetched.identifier == stop.identifier)
                #expect(fetched.name == stop.name)
            } else {
                Issue.record("Failed to refetch stop by id: \(stop.identifier)")
            }
        }
    }
}
