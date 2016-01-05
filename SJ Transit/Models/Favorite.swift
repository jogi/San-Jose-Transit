//
//  FavoriteStop.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/10/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite


enum FavoriteType: Int {
    case FavoriteRoute = 0
    case FavoriteStop
}

class Favorite: NSObject {
    var favoriteId: Int!
    var sortOrder: Int?
    var type: FavoriteType!
    var typeId: String!
    var favorite: AnyObject?
    
    class func favorites() -> [[Favorite]] {
        var favoritesList = [[Favorite]]()
        
        let db = Database.favoritesConnection!
        let favoritesTable = Table("favorites")
        
        // columns
        let colFavoriteId = Expression<Int>("fav_id")
        let colSortOrder = Expression<Int?>("sort_order")
        let colType = Expression<Int>("fav_type")
        let colTypeId = Expression<String>("fav_type_id")
        
        var stopList = [Favorite]()
        var routeList = [Favorite]()
        
        for row in db.prepare(favoritesTable.select(favoritesTable[colFavoriteId], favoritesTable[colSortOrder], favoritesTable[colType], favoritesTable[colTypeId]).order(colSortOrder)) {
            let favorite = Favorite()
            favorite.favoriteId = row[colFavoriteId]
            favorite.sortOrder = row[colSortOrder]
            favorite.type = FavoriteType(rawValue: row[colType])
            favorite.typeId = row[colTypeId]
            
            if favorite.type == .FavoriteStop {
                favorite.favorite = Stop.stop(byId: row[colTypeId])
                stopList.append(favorite)
            } else {
                favorite.favorite = Route.route(byId: row[colTypeId])
                routeList.append(favorite)
            }
        }
        
        if (routeList.count > 0) { favoritesList.append(routeList) }
        if (stopList.count > 0) { favoritesList.append(stopList) }
        
        return favoritesList
    }
    
    
    class func addFavorite(favoriteType: FavoriteType, typeId: String) {
        let db = Database.favoritesConnection!
        let favorites = Table("favorites")
        
        let colTypeId = Expression<String>("fav_type_id")
        let colType = Expression<Int>("fav_type")
        do {
            let rowid = try db.run(favorites.insert(colTypeId <- typeId, colType <- favoriteType.rawValue))
            print("Favorite inserted id: \(rowid)")
        } catch {
            print("Favorite insertion failed: \(error)")
        }
    }
    
    
    class func deleteFavorite(favoriteId: Int) {
        let db = Database.favoritesConnection!
        let favorites = Table("favorites")
        
        let colFavoriteId = Expression<Int>("fav_id")
        do {
            let specificFavorite = favorites.filter(colFavoriteId == favoriteId)
            if try db.run(specificFavorite.delete()) > 0 {
                print("deleted fav: \(favoriteId)")
            } else {
                print("favorite not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
    }
    
    
    class func updateFavorites(favorites: [Favorite]) {
        let db = Database.favoritesConnection!
        let favoritesTable = Table("favorites")
        
        // columns
        let colFavoriteId = Expression<Int>("fav_id")
        let colSortOrder = Expression<Int>("sort_order")
        let colType = Expression<Int>("fav_type")
        let colTypeId = Expression<String>("fav_type_id")
        
        for aFavorite in favorites {
            let specificFavorite = favoritesTable.filter(colFavoriteId == aFavorite.favoriteId)
            do {
                let rowid = try db.run(specificFavorite.update(colSortOrder <- aFavorite.sortOrder!, colType <- aFavorite.type.rawValue, colTypeId <- aFavorite.typeId))
                print("favorite updated id: \(rowid)")
            } catch {
                print("favroite update failed: \(error)")
            }
        }
    }
}
