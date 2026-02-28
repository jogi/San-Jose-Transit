import Foundation
import Testing
@testable import SJ_Transit
import GTFSModel

@Suite struct FavoriteQueryTests {
    @Test func favorites_crud_and_queries() throws {
        try TestDBSupport.ensureGTFSInstalled()
        TestDBSupport.resetFavoritesDB()

        #expect(Favorite.favorites().isEmpty)

        let route = Route.routes().first
        let stop = Stop.stops().first
        if route?.identifier == nil || stop?.identifier == nil {
            Issue.record("Missing a route or stop to favorite from GTFS DB")
            return
        }
        let routeIdentifier = route!.identifier
        let stopIdentifier = stop!.identifier

        Favorite.addFavorite(.favoriteRoute, typeId: routeIdentifier)
        Favorite.addFavorite(.favoriteStop, typeId: stopIdentifier)

        #expect(Favorite.isFavorite(.favoriteRoute, typeId: routeIdentifier))
        #expect(Favorite.isFavorite(.favoriteStop, typeId: stopIdentifier))

        var groups = Favorite.favorites()
        #expect(!groups.isEmpty)
        var flat = groups.flatMap { $0 }
        #expect(flat.count >= 2)

        for (idx, favorite) in flat.enumerated() {
            favorite.sortOrder = (flat.count - idx)
        }
        Favorite.updateFavorites(flat)

        groups = Favorite.favorites()
        flat = groups.flatMap { $0 }
        #expect(flat.map { $0.sortOrder! } == flat.map { $0.sortOrder! }.sorted(by: >))

        if let firstId = flat.first?.favoriteId {
            Favorite.deleteFavorite(firstId)
        }
        Favorite.deleteFavorite(.favoriteRoute, typeId: routeIdentifier)

        #expect(!Favorite.isFavorite(.favoriteRoute, typeId: routeIdentifier))
    }
}
