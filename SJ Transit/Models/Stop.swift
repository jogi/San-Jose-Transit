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

public class Stop: NSObject, MKAnnotation {
    var stopId: String!
    var stopName: String?
    var stopDescription: String?
    var latitude: Double!
    var longitude: Double!
    var routes: String?
    
    
    // MARK: - MKAnnotation protocol
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(self.latitude, self.longitude)
        }
    }
    
    public var title: String? {
        get {
            return self.stopName
        }
    }
    
    public var subtitle: String? {
        get {
            return self.routes
        }
    }
    
    
    // MARK: - Methods
    public class func fetchAllStops() -> (Array <Stop>) {
        let path = NSBundle.mainBundle().pathForResource("vta_gtfs", ofType: "db")!
        var stopsList = Array<Stop>()
        
        var db = Connection!()
        do {
            db = try Connection(path, readonly: true)
            
            let stops = Table("stops")
            
            for stop in db.prepare(stops) {
                let aStop = Stop()
                aStop.stopId = stop[Expression<String>("stop_id")]
                aStop.stopName = stop[Expression<String?>("stop_name")]
                aStop.stopDescription = stop[Expression<String?>("stop_desc")]
                aStop.latitude = stop[Expression<Double>("stop_lat")]
                aStop.longitude = stop[Expression<Double>("stop_lon")]
                aStop.routes = stop[Expression<String?>("routes")]
                
                stopsList.append(aStop)
            }
        } catch {
            stopsList = []
        }

        
        
        return stopsList
    }
}
