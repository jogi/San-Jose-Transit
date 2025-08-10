//
//  FavoriteQueryTests.swift
//

import Foundation
import Testing
@testable import SJ_Transit

@Suite struct FavoriteQueryTests {
    @Test func favorites_crud_and_queries() throws {
        try TestDBSupport.ensureGTFSInstalled()
        TestDBSupport.resetFavoritesDB()

        // Start clean
        #expect(Favorite.favorites().isEmpty)

        // Pick a route and stop to favorite
        let route = Route.routes().first
        let stop = Stop.stops().first
        if route?.routeId == nil || stop?.stopId == nil {
            Issue.record("Missing a route or stop to favorite from GTFS DB")
            return
        }
        let routeId = route!.routeId!
        let stopId = stop!.stopId!

        // Add
        Favorite.addFavorite(.favoriteRoute, typeId: routeId)
        Favorite.addFavorite(.favoriteStop, typeId: stopId)

        #expect(Favorite.isFavorite(.favoriteRoute, typeId: routeId))
        #expect(Favorite.isFavorite(.favoriteStop, typeId: stopId))

        // List grouped favorites
        var groups = Favorite.favorites()
        #expect(!groups.isEmpty)
        // Flatten for updates
        var flat = groups.flatMap { $0 }
        #expect(flat.count >= 2)

        // Update order (reverse) and verify
        for (idx, fav) in flat.enumerated() {
            fav.sortOrder = (flat.count - idx)
        }
        Favorite.updateFavorites(flat)

        groups = Favorite.favorites()
        flat = groups.flatMap { $0 }
        #expect(flat.map { $0.sortOrder! } == flat.map { $0.sortOrder! }.sorted(by: >))

        // Delete by id
        if let firstId = flat.first?.favoriteId { Favorite.deleteFavorite(firstId) }
        // Delete by composite
        Favorite.deleteFavorite(.favoriteRoute, typeId: routeId)

        #expect(!Favorite.isFavorite(.favoriteRoute, typeId: routeId))
    }
}
