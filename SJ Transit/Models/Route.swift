//
//  Route.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite


enum RouteType: Int, CustomStringConvertible {
    case lightRail = 0
    case subway = 1
    case rail = 2
    case bus = 3
    case ferry = 4
    case cableCar = 5
    case gondola = 6
    case funicular = 7
    
    var description: String {
        switch self {
        case .lightRail: return "Light Rail"
        case .subway: return "Subway"
        case .rail: return "Rail"
        case .bus: return "Bus"
        case .ferry: return "Ferry"
        case .cableCar: return "Cable Car"
        case .gondola: return "Gondola"
        case .funicular: return "Funicular"
        }
    }
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
        // For numeric sorting of string short names (e.g., "2" before "10")
        let colRouteShortNameInt = Expression<Int?>("CAST(route_short_name AS INTEGER)")
        
        do {
            for route in try db.prepare(routes.order(colRouteShortNameInt.asc, colRouteShortName.asc)) {
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
