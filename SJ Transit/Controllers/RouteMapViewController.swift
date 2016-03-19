//
//  RouteMapViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/10/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import MapKit

class RouteMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var times: [StopTime] = [StopTime]()
    var tripId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Route Map"
        self.mapRoute()
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
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0;
        renderer.strokeColor = mapView.tintColor
        
        return renderer
    }
    
    
    // MARK: - Controller methods
    func mapRoute() {
        self.mapView.addAnnotations(self.times)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let shapes = Shape.shapes(forTrip:strongSelf.tripId!)
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
