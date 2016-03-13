//
//  Route.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite


enum RouteType: Int {
    case LightRail = 0
    case Subway = 1
    case Rail = 2
    case Bus = 3
    case Ferry = 4
    case CableCar = 5
    case Gondola = 6
    case Funicular = 7
}


class Route: NSObject {
    var routeLongName: String!
    var routeShortName: String!
    var routeType: RouteType!
    var routeId: String!
    var agencyId: String?
    
    
    convenience init(routeId: String?, routeShortName: String?, routeLongName: String?, routeType: RouteType?, agencyId: String?) {
        self.init()
        self.routeId = routeId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
        self.routeType = routeType
        self.agencyId = agencyId
    }
    
    // MARK: - Methods
    class func routes() -> (Array <Route>) {
        guard let db = Database.connection else {
            return []
        }
        
        var routeList = Array<Route>()
        let routes = Table("routes")
        
        // columns
        let colRouteId = Expression<String>("route_id")
        let colRouteType = Expression<Int>("route_type")
        let colRouteLongName = Expression<String>("route_long_name")
        let colRouteShortName = Expression<String?>("route_short_name")
        
        do {
            for route in try db.prepare(routes.order(cast(colRouteShortName) as Expression<Int?>, colRouteShortName)) {
                let aRoute = Route()
                aRoute.routeId = route[colRouteId]
                aRoute.routeType = RouteType(rawValue: route[colRouteType])
                aRoute.routeLongName = route[colRouteLongName]
                aRoute.routeShortName = route[colRouteShortName]
                
                routeList.append(aRoute)
            }
        }catch _ {}
        
        return routeList
    }
    
    
    class func route(byId routeId: String) -> Route? {
        guard let db = Database.connection else {
            return nil
        }
        
        let routes = Table("routes")
        var route: Route?
        
        // columns
        let colRouteId = Expression<String>("route_id")
        let colRouteType = Expression<Int>("route_type")
        let colRouteLongName = Expression<String>("route_long_name")
        let colRouteShortName = Expression<String?>("route_short_name")
        
        do {
            for row in try db.prepare(routes.filter(colRouteId == routeId)) {
                route = Route(routeId: row[colRouteId], routeShortName: row[colRouteShortName], routeLongName: row[colRouteLongName], routeType: RouteType(rawValue: row[colRouteType]), agencyId: nil)
            }
        } catch _ {}
        
        return route
    }
}
