//
//  Trip.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite


enum Direction: Int {
    case Outbound
    case Inbound
    
    var description: String {
        switch (self) {
            case .Outbound: return "Outbound"
            case .Inbound: return "Inbound"
        }
    }
}

class Trip: NSObject {
    var routeId: String!
    var tripHeadsign: String!
    var serviceId: String!
    var tripId: String!
    var directionId: Direction!
    var shapeId: String!
    
    convenience init(tripId: String?, routeId: String?, serviceId: String?, tripHeadsign: String?, directionId: Direction?, shapeId: String?) {
        self.init()
        self.tripId = tripId
        self.tripHeadsign = tripHeadsign
        self.serviceId = serviceId
        self.routeId = routeId
        self.directionId = directionId
        self.shapeId = shapeId
    }
    
    // get all trip ids which are active today
    class func trips(routeIds: Array<String>, activeOn: NSDate) -> (Array<String>) {
        guard let db = Database.connection else {
            return []
        }
        
        var tripIds = Array<String>()
        let trips = Table("trips")
        
        // columns
        let colRouteId = Expression<String>("route_id")
        let colTripId = Expression<String>("trip_id")
        let colServiceId = Expression<String>("service_id")
        
        do  {
            for trip in try db.prepare(trips.select(colTripId, colServiceId).filter(routeIds.contains(colRouteId))) {
                // check if it is active
                if Calendar.isServiceActive(activeOn, serviceId: trip[colServiceId]) {
                    tripIds.append(trip[colTripId])
                }
            }
        } catch _ {}
        
        return tripIds
    }
    
    
    // get all trip ids which are active today in a specific direction
    class func trips(routeIds: Array<String>, directionId: Direction!, activeOn: NSDate) -> (Array<String>) {
        guard let db = Database.connection else {
            return []
        }
        
        var tripIds = Array<String>()
        let trips = Table("trips")
        
        // columns
        let colRouteId = Expression<String>("route_id")
        let colTripId = Expression<String>("trip_id")
        let colDirectionId = Expression<Int>("direction_id")
        let colServiceId = Expression<String>("service_id")
        
        do {
            for trip in try db.prepare(trips.select(colTripId, colServiceId).filter(routeIds.contains(colRouteId) && trips[colDirectionId] == directionId.rawValue)) {
                // check if it is active
                if Calendar.isServiceActive(activeOn, serviceId: trip[colServiceId]) {
                    tripIds.append(trip[colTripId])
                }
            }
        } catch _ {}
        
        return tripIds
    }
}
