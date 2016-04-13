//
//  TripDetailViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/8/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import MapKit
import Crashlytics

class TripDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var stopTime: StopTime?
    var times: Array<StopTime> = Array<StopTime>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.stopTime?.trip.tripHeadsign
        
        self.tableView.registerIdentifiableCell(TripStopTableViewCell.self)
        
        self.fetchTripDetail()
        self.mapRoute()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEventWithName("Show Trip Detail", customAttributes: nil)
    }
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.times.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(TripStopTableViewCell.self, forIndexPath: indexPath)
        
        // Configure the cell...
        cell.stopTime = self.times[indexPath.row]
        cell.topLineView.hidden = indexPath.row == 0
        cell.bottomLineView.hidden = indexPath.row == (self.times.count - 1)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.presentStopOptions(self.times[indexPath.row])
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView?
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("stopPin") as? MKPinAnnotationView
            
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "stopPin")
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = mapView.tintColor
                
                let disclosureButton = UIButton(type: .DetailDisclosure)
                disclosureButton.setImage(UIImage(named: "right-arrow"), forState: .Normal) // yup, annotation views are stupid, so try to trick it
                annotationView?.rightCalloutAccessoryView = disclosureButton
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stopTime = view.annotation as? StopTime
        self.presentStopOptions(stopTime!)
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0;
        renderer.strokeColor = mapView.tintColor
        
        return renderer
    }
    
    
    // MARK: - IBActions
    @IBAction func locateMe(sender: AnyObject) {
        self.animateMapRegion(to: self.mapView.userLocation.coordinate)
    }
    
    
    // MARK: - Controller methods
    func presentStopOptions(stopTime: StopTime) {
        // present action sheet with options
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Stop Schedule", style: .Default, handler: { _ -> Void in
            let stopRouteTimeController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteTimesViewController") as! StopRouteTimesViewController
            stopTime.route.routeId = self.stopTime?.route.routeId
            stopRouteTimeController.stopTime = stopTime
            
            self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Stop Lines", style: .Default, handler: { _ -> Void in
            let stopRouteController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteViewController") as! StopRouteViewController
            stopRouteController.stop = stopTime.stop
            
            self.navigationController?.pushViewController(stopRouteController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Show on Map", style: .Default, handler: { _ -> Void in
            self.animateMapRegion(to: stopTime.stop.coordinate)
            self.mapView.selectAnnotation(stopTime, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func fetchTripDetail() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.times = StopTime.stopTimes((strongSelf.stopTime?.trip.tripId)!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                strongSelf.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                strongSelf.mapView.addAnnotations(strongSelf.times)
                
                // focus the selected stop
                let stopTimes = strongSelf.times.filter({ (stopTime) -> Bool in
                    return stopTime.stop.stopId == strongSelf.stopTime?.stop.stopId
                })
                
                if stopTimes.count > 0 {
                    strongSelf.animateMapRegion(to: (stopTimes[0].stop.coordinate))
                    strongSelf.mapView.selectAnnotation(stopTimes[0], animated: true)
                }
            });
        });
    }
    
    
    func mapRoute() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let shapes = Shape.shapes(forShape:(strongSelf.stopTime?.trip.shapeId)!)
            var points = [CLLocationCoordinate2D]()
            
            for aShape in shapes {
                points.append(aShape.coordinate)
            }
            
            let polyline = MKPolyline(coordinates: &points[0], count: shapes.count)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                strongSelf.mapView.addOverlay(polyline)
                strongSelf.animateMapRegion(to: shapes[0].coordinate)
            });
        });
    }
    
    
    func animateMapRegion(to coordinate:CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    deinit {
        self.mapView.delegate = nil
    }
}
