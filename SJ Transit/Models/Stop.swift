//
//  Stop.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite
import MapKit

class Stop: NSObject, MKAnnotation {
    var stopId: String!
    var stopName: String!
    var stopDescription: String?
    var latitude: Double!
    var longitude: Double!
    var routes: String?
    
    
    // MARK: - MKAnnotation protocol
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(self.latitude, self.longitude)
        }
    }
    
    var title: String? {
        get {
            return self.stopName
        }
    }
    
    var subtitle: String? {
        get {
            return self.routes
        }
    }
    
    
    convenience init(stopId: String?, stopName: String?, stopDescription: String?, latitude: Double?, longitude: Double?, routes: String?) {
        self.init()
        self.stopId = stopId
        self.stopName = stopName
        self.stopDescription = stopDescription
        self.latitude = latitude
        self.longitude = longitude
        self.routes = routes
    }
    
    
    // MARK: - Methods
    class func stops() -> (Array <Stop>) {
        var stopsList = Array<Stop>()
        
        guard let db = Database.connection else {
            return []
        }
        
        let stops = Table("stops")
        
        do {
            for stop in try db.prepare(stops) {
                let aStop = Stop()
                aStop.stopId = stop[Expression<String>("stop_id")]
                aStop.stopName = stop[Expression<String>("stop_name")]
                aStop.stopDescription = stop[Expression<String?>("stop_desc")]
                aStop.latitude = stop[Expression<Double>("stop_lat")]
                aStop.longitude = stop[Expression<Double>("stop_lon")]
                aStop.routes = stop[Expression<String?>("routes")]
                
                stopsList.append(aStop)
            }
        } catch _ {}

        return stopsList
    }
    
    
    class func stop(byId stopId: String) -> Stop? {
        guard let db = Database.connection else {
            return nil
        }
        
        let stops = Table("stops")
        var stop: Stop?
        
        let colStopId = Expression<String>("stop_id")
        let colStopName = Expression<String>("stop_name")
        let colRoutes = Expression<String>("routes")
        
        do {
            for row in try db.prepare(stops.filter(colStopId == stopId)) {
                stop = Stop(stopId: row[colStopId], stopName: row[colStopName], stopDescription: nil, latitude: nil, longitude: nil, routes: row[colRoutes])
            }
        } catch _ {}
        
        return stop
    }
}
