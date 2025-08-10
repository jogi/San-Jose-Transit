//
//  StopTime.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite
import CoreLocation
import MapKit

class StopTime: NSObject, MKAnnotation {
    var arrivalTime: Date!
    var departureTime: Date!
    var stopSequence: Int!
    var isTimepoint: Bool!
    var isLastStop: Bool!
    // non table attributes
    var stop: Stop = Stop()
    var trip: Trip = Trip()
    var route: Route = Route()
    
    
    // MARK: - MKAnnotation protocol
    var coordinate: CLLocationCoordinate2D {
        get {
            return self.stop.coordinate
        }
    }
    
    var title: String? {
        get {
            return self.stop.stopName
        }
    }
    
    var subtitle: String? {
        get {
            return self.arrivalTime.timeWithMeridianAsString
        }
    }
    
    // get stop times for a stop for specified tripIds
    class func stopTimes(_ stopId: String!, afterTime: Date!, tripIds: Array<String>!) -> (Array<StopTime>) {
        guard let db = Database.connection else {
            return []
        }
        
        var times = Array<StopTime>()
        let stopTimes = Table("stop_times")
        let trips = Table("trips")
        let routes = Table("routes")
        
        // columns
        let colStopId = Expression<String>("stop_id")
        let colTripId = Expression<String>("trip_id")
        let colArrivalTime = Expression<String>("arrival_time")
        let colTripHeadSign = Expression<String>("trip_headsign")
        let colRouteId = Expression<String>("route_id")
        let colDirectionId = Expression<Int>("direction_id")
        let colRouteShortName = Expression<String>("route_short_name")
        let colIsLastStop = Expression<Bool>("is_laststop")
        
        let query = stopTimes.select(stopTimes[colArrivalTime].min, trips[colRouteId], routes[colRouteShortName], trips[colDirectionId], trips[colTripHeadSign]).join(trips, on: stopTimes[colTripId] == trips[colTripId]).join(routes, on: trips[colRouteId] == routes[colRouteId]).filter(stopTimes[colStopId] == stopId && tripIds.contains(stopTimes[colTripId]) && stopTimes[colArrivalTime] >= DateFormatter.SQLTimeFormatter.string(from: afterTime) && stopTimes[colIsLastStop] == false).group(trips[colRouteId]).order(trips[colRouteId], stopTimes[colArrivalTime])
        
        do {
            for stopTime in try db.prepare(query) {
                let aStopTime = StopTime()
                aStopTime.arrivalTime = DateFormatter.SQLTimeFormatter.date(from: stopTime[stopTimes[colArrivalTime].min]!.sanitizedTimeString)
                aStopTime.trip = Trip(tripId: nil, routeId: stopTime[trips[colRouteId]], serviceId: nil, tripHeadsign: stopTime[trips[colTripHeadSign]], directionId: Direction(rawValue: stopTime[trips[colDirectionId]]), shapeId: nil)
                aStopTime.route = Route(routeId: stopTime[trips[colRouteId]], routeShortName: stopTime[routes[colRouteShortName]], routeLongName: nil, routeType: nil, agencyId: nil)
                
                times.append(aStopTime)
            }
        } catch {
            print("Error getting stop-times: \(error)")
        }
        
        return times
    }
    
    
    class func stopTimes(_ stopId: String!, routeId: String!, tripIds: Array<String>!, afterTime: Date!) -> (Array<StopTime>) {
        guard let db = Database.connection else {
            return []
        }
        
        var times = Array<StopTime>()
        let stopTimes = Table("stop_times")
        let trips = Table("trips")
        
        // columns
        let colStopId = Expression<String>("stop_id")
        let colTripId = Expression<String>("trip_id")
        let colArrivalTime = Expression<String>("arrival_time")
        let colRouteId = Expression<String>("route_id")
        let colTripHeadSign = Expression<String>("trip_headsign")
        let colIsLastStop = Expression<Bool>("is_laststop")
        let colShapeId = Expression<String>("shape_id")
        let colDirectionId = Expression<Int>("direction_id")
        
        let query = stopTimes.select(stopTimes[colArrivalTime], trips[colTripHeadSign], trips[colTripId], trips[colShapeId], trips[colDirectionId]).join(trips, on: stopTimes[colTripId] == trips[colTripId]).filter(stopTimes[colStopId] == stopId && trips[colRouteId] == routeId && tripIds.contains(stopTimes[colTripId]) && stopTimes[colArrivalTime] >= DateFormatter.SQLTimeFormatter.string(from: afterTime) && stopTimes[colIsLastStop] == false).order(stopTimes[colArrivalTime])
        
        do  {
            for stopTime in try db.prepare(query) {
                let aStopTime = StopTime()
                aStopTime.arrivalTime = DateFormatter.SQLTimeFormatter.date(from: stopTime[stopTimes[colArrivalTime]].sanitizedTimeString)
                aStopTime.trip = Trip(tripId: stopTime[trips[colTripId]], routeId: nil, serviceId: nil, tripHeadsign: stopTime[trips[colTripHeadSign]], directionId: Direction(rawValue: stopTime[trips[colDirectionId]]), shapeId: stopTime[trips[colShapeId]])
                aStopTime.route = Route(routeId: routeId, routeShortName: nil, routeLongName: nil, routeType: nil, agencyId: nil)
                
                times.append(aStopTime)
            }
        } catch _ {}
        
        return times
    }
    
    
    class func stopTimes(_ tripId: String) -> (Array<StopTime>) {
        guard let db = Database.connection else {
            return []
        }
        
        var times = Array<StopTime>()
        let stopTimes = Table("stop_times")
        let stops = Table("stops")
        
        // columns
        let colStopId = Expression<String>("stop_id")
        let colStopLat = Expression<Double>("stop_lat")
        let colStopLon = Expression<Double>("stop_lon")
        let colTripId = Expression<String>("trip_id")
        let colArrivalTime = Expression<String>("arrival_time")
        let colStopName = Expression<String>("stop_name")
        let colRoutes = Expression<String>("routes")
        let colStopSequence = Expression<Int>("stop_sequence")
        
        let query = stopTimes.select(stopTimes[colArrivalTime], stopTimes[colStopId], stopTimes[colStopSequence], stops[colStopName], stops[colStopLat], stops[colStopLon], stops[colRoutes]).join(stops, on: stopTimes[colStopId] == stops[colStopId]).filter(stopTimes[colTripId] == tripId).order(stopTimes[colStopSequence])
        
        do {
            for stopTime in try db.prepare(query) {
                let aStopTime = StopTime()
                aStopTime.arrivalTime = DateFormatter.SQLTimeFormatter.date(from: stopTime[stopTimes[colArrivalTime]].sanitizedTimeString)
                aStopTime.stopSequence = stopTime[stopTimes[colStopSequence]]
                aStopTime.stop = Stop(stopId: stopTime[stopTimes[colStopId]], stopName: stopTime[stops[colStopName]], stopDescription: nil, latitude: stopTime[stops[colStopLat]], longitude: stopTime[stops[colStopLon]], routes: stopTime[stops[colRoutes]])
                
                times.append(aStopTime)
            }
        } catch _ {}
        
        return times
    }
    
    
    class func trip(_ routeId: String!, directionId: Direction!, afterTime: Date!) -> (String?) {
        guard let db = Database.connection else {
            return nil
        }
        
        var tripId: String?
        
        // find trips ids active today
        let tripIds = Trip.trips([routeId], directionId: directionId, activeOn: afterTime)
        let stopTimes = Table("stop_times")
        
        // columns
        let colTripId = Expression<String>("trip_id")
        let colArrivalTime = Expression<String>("arrival_time")
        let colStopSequence = Expression<Int>("stop_sequence")
        
        do {
            for row in try db.prepare(stopTimes.select(colTripId).filter(tripIds.contains(colTripId) && colStopSequence == 1 && colArrivalTime >= DateFormatter.SQLTimeFormatter.string(from: afterTime)).order(colArrivalTime).limit(1)) {
                tripId = row[colTripId]
            }
        } catch _ {}
        
        return tripId
    }
    
    
    override var description : String {
        return "<\(String(describing: self.stop.stopId)), \(String(describing: self.arrivalTime)), \(String(describing: self.departureTime)), \(self.route.routeId!), \(self.route.routeShortName!), \(self.trip.directionId!), \(self.trip.tripHeadsign!)>\n"
    }
}
