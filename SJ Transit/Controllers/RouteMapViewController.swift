//
//  RouteMapViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/10/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import MapKit
import Crashlytics

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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Route Map", customAttributes: nil)
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
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0;
        renderer.strokeColor = mapView.tintColor
        
        return renderer
    }
    
    
    // MARK: - Controller methods
    func mapRoute() {
        self.mapView.addAnnotations(self.times)
        
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let shapes = Shape.shapes(forTrip:strongSelf.tripId!)
            var points = [CLLocationCoordinate2D]()
            
            for aShape in shapes {
                points.append(aShape.coordinate)
            }
            
            let polyline = MKPolyline(coordinates: &points[0], count: shapes.count)
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.mapView.add(polyline)
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
