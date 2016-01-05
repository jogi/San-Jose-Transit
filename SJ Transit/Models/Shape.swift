//
//  Shape.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/8/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite
import CoreLocation

class Shape: NSObject {
    var shapeId: String?
    var pointLat: Double!
    var pointLon: Double!
    var pointSequence: Int!
    var distanceTraveled: Double?
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(self.pointLat, self.pointLon)
        }
    }
    
    // MARK: - Methods
    class func shapes(forShape shapeId: String) -> (Array<Shape>) {
        var shapeList = Array<Shape>()
        
        let db = Database.connection
        let shapes = Table("shapes")
        
        // columns
        let colShapeId = Expression<String>("shape_id")
        let colLatitude = Expression<Double>("shape_pt_lat")
        let colLongitude = Expression<Double>("shape_pt_lon")
        let colPointSequence = Expression<Int>("shape_pt_sequence")
        
        for row in db!.prepare(shapes.select(colLatitude, colLongitude, colPointSequence).filter(colShapeId == shapeId).order(colPointSequence)) {
            let aShape = Shape()
            aShape.pointLat = row[colLatitude]
            aShape.pointLon = row[colLongitude]
            aShape.pointSequence = row[colPointSequence]
            
            shapeList.append(aShape)
        }
        
        return shapeList
    }
    
    
    class func shapes(forTrip tripId: String) -> (Array<Shape>) {
        var shapeList = Array<Shape>()
        
        let db = Database.connection
        let shapes = Table("shapes")
        let trips = Table("trips")
        
        // columns
        let colShapeId = Expression<String>("shape_id")
        let colLatitude = Expression<Double>("shape_pt_lat")
        let colLongitude = Expression<Double>("shape_pt_lon")
        let colPointSequence = Expression<Int>("shape_pt_sequence")
        let colTripId = Expression<String>("trip_id")
        
        for row in db!.prepare(shapes.select(shapes[colLatitude], shapes[colLongitude], shapes[colPointSequence]).join(trips, on: shapes[colShapeId] == trips[colShapeId]).filter(trips[colTripId] == tripId).order(shapes[colPointSequence])) {
            let aShape = Shape()
            aShape.pointLat = row[shapes[colLatitude]]
            aShape.pointLon = row[shapes[colLongitude]]
            aShape.pointSequence = row[shapes[colPointSequence]]
            
            shapeList.append(aShape)
        }
        
        return shapeList
    }
}
