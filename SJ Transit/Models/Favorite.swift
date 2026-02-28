import Foundation
import GRDB
import GTFSModel

enum FavoriteType: Int {
    case favoriteRoute = 0
    case favoriteStop
}

private struct FavoriteRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "favorites"

    var favoriteId: Int64?
    var sortOrder: Int?
    var favoriteType: Int
    var typeIdentifier: String

    enum CodingKeys: String, CodingKey {
        case favoriteId = "fav_id"
        case sortOrder = "sort_order"
        case favoriteType = "fav_type"
        case typeIdentifier = "fav_type_id"
    }
}

class Favorite: NSObject {
    var favoriteId: Int!
    var sortOrder: Int?
    var type: FavoriteType!
    var typeId: String!
    var favorite: Any?

    class func favorites() -> [[Favorite]] {
        guard let dbQueue = Database.favoritesConnection else {
            return []
        }

        do {
            let records = try dbQueue.read { db in
                try FavoriteRecord
                    .order(Column("sort_order"), Column("fav_id"))
                    .fetchAll(db)
            }

            let routeIdentifiers = records.compactMap { record -> String? in
                guard FavoriteType(rawValue: record.favoriteType) == .favoriteRoute else {
                    return nil
                }
                return record.typeIdentifier
            }
            let stopIdentifiers = records.compactMap { record -> String? in
                guard FavoriteType(rawValue: record.favoriteType) == .favoriteStop else {
                    return nil
                }
                return record.typeIdentifier
            }

            let routeMap = routesByIdentifier(Set(routeIdentifiers))
            let stopMap = stopsByIdentifier(Set(stopIdentifiers))

            var routeList: [Favorite] = []
            var stopList: [Favorite] = []

            for record in records {
                guard let favorite = makeFavorite(from: record, routeMap: routeMap, stopMap: stopMap) else {
                    continue
                }

                if favorite.type == .favoriteRoute {
                    routeList.append(favorite)
                } else {
                    stopList.append(favorite)
                }
            }

            var favoritesList: [[Favorite]] = []
            if routeList.isEmpty == false {
                favoritesList.append(routeList)
            }
            if stopList.isEmpty == false {
                favoritesList.append(stopList)
            }
            return favoritesList
        } catch {
            return []
        }
    }

    class func isFavorite(_ favoriteType: FavoriteType, typeId: String) -> Bool {
        guard let dbQueue = Database.favoritesConnection else {
            return false
        }

        do {
            return try dbQueue.read { db in
                let count = try FavoriteRecord
                    .filter(Column("fav_type_id") == typeId)
                    .filter(Column("fav_type") == favoriteType.rawValue)
                    .fetchCount(db)
                return count > 0
            }
        } catch {
            return false
        }
    }

    class func addFavorite(_ favoriteType: FavoriteType, typeId: String) {
        guard let dbQueue = Database.favoritesConnection else {
            return
        }

        do {
            try dbQueue.write { db in
                try FavoriteRecord(
                    favoriteId: nil,
                    sortOrder: nil,
                    favoriteType: favoriteType.rawValue,
                    typeIdentifier: typeId
                ).insert(db)
            }
        } catch {
            print("Favorite insertion failed: \(error)")
        }
    }

    class func deleteFavorite(_ favoriteId: Int) {
        guard let dbQueue = Database.favoritesConnection else {
            return
        }

        do {
            try dbQueue.write { db in
                _ = try FavoriteRecord
                    .filter(Column("fav_id") == favoriteId)
                    .deleteAll(db)
            }
        } catch {
            print("Favorite delete failed: \(error)")
        }
    }

    class func deleteFavorite(_ favoriteType: FavoriteType, typeId: String) {
        guard let dbQueue = Database.favoritesConnection else {
            return
        }

        do {
            try dbQueue.write { db in
                _ = try FavoriteRecord
                    .filter(Column("fav_type_id") == typeId)
                    .filter(Column("fav_type") == favoriteType.rawValue)
                    .deleteAll(db)
            }
        } catch {
            print("Favorite delete failed: \(error)")
        }
    }

    class func updateFavorites(_ favorites: [Favorite]) {
        guard let dbQueue = Database.favoritesConnection else {
            return
        }

        do {
            try dbQueue.write { db in
                for favorite in favorites {
                    guard let type = favorite.type,
                          let typeId = favorite.typeId,
                          let favoriteId = favorite.favoriteId else {
                        continue
                    }

                    _ = try FavoriteRecord
                        .filter(Column("fav_id") == favoriteId)
                        .updateAll(
                            db,
                            [
                                Column("sort_order").set(to: favorite.sortOrder),
                                Column("fav_type").set(to: type.rawValue),
                                Column("fav_type_id").set(to: typeId)
                            ]
                        )
                }
            }
        } catch {
            print("Favorite update failed: \(error)")
        }
    }

    class func createFavoritesIfRequred() {
        guard let dbQueue = Database.favoritesConnection else {
            return
        }

        do {
            try dbQueue.write { db in
                try db.create(table: FavoriteRecord.databaseTableName, ifNotExists: true) { table in
                    table.autoIncrementedPrimaryKey("fav_id")
                    table.column("fav_type", .integer).notNull()
                    table.column("fav_type_id", .text).notNull()
                    table.column("sort_order", .integer)
                }
                try db.create(
                    index: "idx_favorites_type_type_id",
                    on: FavoriteRecord.databaseTableName,
                    columns: ["fav_type", "fav_type_id"],
                    ifNotExists: true
                )
                try db.create(
                    index: "idx_favorites_sort_order",
                    on: FavoriteRecord.databaseTableName,
                    columns: ["sort_order"],
                    ifNotExists: true
                )
            }
        } catch {
            print("Failed to create Favorites table: \(error)")
        }
    }

    private class func makeFavorite(from record: FavoriteRecord, routeMap: [String: Route], stopMap: [String: Stop]) -> Favorite? {
        guard let favoriteId = record.favoriteId,
              let favoriteType = FavoriteType(rawValue: record.favoriteType) else {
            return nil
        }

        let favorite = Favorite()
        favorite.favoriteId = Int(favoriteId)
        favorite.sortOrder = record.sortOrder
        favorite.type = favoriteType
        favorite.typeId = record.typeIdentifier

        switch favoriteType {
        case .favoriteRoute:
            favorite.favorite = routeMap[record.typeIdentifier]
        case .favoriteStop:
            favorite.favorite = stopMap[record.typeIdentifier]
        }

        return favorite
    }

    private class func routesByIdentifier(_ identifiers: Set<String>) -> [String: Route] {
        guard identifiers.isEmpty == false, let dbQueue = Database.connection else {
            return [:]
        }

        let values = Array(identifiers)

        do {
            return try dbQueue.read { db in
                let routes = try Route
                    .filter { values.contains($0.identifier) }
                    .fetchAll(db)
                return Dictionary(uniqueKeysWithValues: routes.map { ($0.identifier, $0) })
            }
        } catch {
            return [:]
        }
    }

    private class func stopsByIdentifier(_ identifiers: Set<String>) -> [String: Stop] {
        guard identifiers.isEmpty == false,
              let dbQueue = Database.connection else {
            return [:]
        }

        do {
            let values = Array(identifiers)
            return try dbQueue.read { db in
                let stops = try Stop
                    .filter { values.contains($0.identifier) }
                    .fetchAll(db)
                return Dictionary(uniqueKeysWithValues: stops.map { ($0.identifier, $0) })
            }
        } catch {
            return [:]
        }
    }
}
