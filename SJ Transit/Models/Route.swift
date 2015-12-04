//
//  Route.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite

public class Route: NSObject {
    var routeLongName: String?
    var routeShortName: String?
    var routeType: NSInteger?
    var routeId: String?
    var agencyId: String?
    
    // MARK: - Methods
    public class func fetchAllRoutes() -> (Array <Route>) {
        let path = NSBundle.mainBundle().pathForResource("vta_gtfs", ofType: "db")!
        var routeList = Array<Route>()
        
        var db = Connection!()
        do {
            db = try Connection(path, readonly: true)
            
            let routes = Table("routes")
            
            // columns
            let colRouteId = Expression<String?>("route_id")
            let colRouteType = Expression<NSInteger?>("route_type")
            let colRouteLongName = Expression<String?>("route_long_name")
            let colRouteShortName = Expression<String?>("route_short_name")
            
            for route in db.prepare(routes.order(colRouteType, colRouteShortName)) {
                let aRoute = Route()
                aRoute.routeId = route[colRouteId]
                aRoute.routeType = route[colRouteType]
                aRoute.routeLongName = route[colRouteLongName]
                aRoute.routeShortName = route[colRouteShortName]
                
                routeList.append(aRoute)
            }
        } catch {
            routeList = []
        }
        
        
        
        return routeList
    }
}
