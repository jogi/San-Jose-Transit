//
//  TripDetailViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/8/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import MapKit

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
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(TripStopTableViewCell.self, forIndexPath: indexPath)
        
        // Configure the cell...
        cell.stopTime = self.times[(indexPath as NSIndexPath).row]
        cell.topLineView.isHidden = (indexPath as NSIndexPath).row == 0
        cell.bottomLineView.isHidden = (indexPath as NSIndexPath).row == (self.times.count - 1)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.presentStopOptions(self.times[(indexPath as NSIndexPath).row])
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        } else {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stopPin") as? MKPinAnnotationView
            
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "stopPin")
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = mapView.tintColor
                
                let disclosureButton = UIButton(type: .detailDisclosure)
                disclosureButton.setImage(UIImage(named: "right-arrow"), for: UIControl.State()) // yup, annotation views are stupid, so try to trick it
                annotationView?.rightCalloutAccessoryView = disclosureButton
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stopTime = view.annotation as? StopTime
        self.presentStopOptions(stopTime!)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0;
        renderer.strokeColor = mapView.tintColor
        
        return renderer
    }
    
    
    // MARK: - IBActions
    @IBAction func locateMe(_ sender: AnyObject) {
        self.animateMapRegion(to: self.mapView.userLocation.coordinate)
    }
    
    
    // MARK: - Controller methods
    func presentStopOptions(_ stopTime: StopTime) {
        // present action sheet with options
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Stop Schedule", style: .default, handler: { _ -> Void in
            let stopRouteTimeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteTimesViewController") as! StopRouteTimesViewController
            stopTime.route.routeId = self.stopTime?.route.routeId
            stopRouteTimeController.stopTime = stopTime
            
            self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Stop Lines", style: .default, handler: { _ -> Void in
            let stopRouteController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteViewController") as! StopRouteViewController
            stopRouteController.stop = stopTime.stop
            
            self.navigationController?.pushViewController(stopRouteController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Show on Map", style: .default, handler: { _ -> Void in
            self.animateMapRegion(to: stopTime.stop.coordinate)
            self.mapView.selectAnnotation(stopTime, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func fetchTripDetail() {
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.times = StopTime.stopTimes((strongSelf.stopTime?.trip.tripId)!)
            
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let shapes = Shape.shapes(forShape:(strongSelf.stopTime?.trip.shapeId)!)
            var points: [CLLocationCoordinate2D] = []
            
            for aShape in shapes {
                points.append(aShape.coordinate)
            }
            
            let polyline = MKPolyline(coordinates: &points, count: points.count)
            
            DispatchQueue.main.async {
                strongSelf.mapView.addOverlay(polyline, level: .aboveRoads)
                strongSelf.animateMapRegion(to: points.first!)
            }
        });
    }
    
    
    func animateMapRegion(to coordinate:CLLocationCoordinate2D) {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    deinit {
        self.mapView.delegate = nil
    }
}
