//
//  RouteMapViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/10/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import MapKit
import GTFSModel

class RouteMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var times: [TripStopSummary] = []
    var tripId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Route Map"
        self.mapRoute()
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKMarkerAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        } else {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stopPin") as? MKMarkerAnnotationView
            
            if (annotationView == nil) {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "stopPin")
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = mapView.tintColor
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
        self.mapView.addAnnotations(self.times.map(StopTimeAnnotation.init))
        
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            guard let tripId = strongSelf.tripId else { return }
            
            let shapes = Shape.shapes(forTrip: tripId)
            var points = [CLLocationCoordinate2D]()
            
            for aShape in shapes {
                points.append(aShape.coordinate)
            }
            guard points.isEmpty == false else { return }
            
            let polyline = MKPolyline(coordinates: &points[0], count: shapes.count)
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.mapView.addOverlay(polyline)
                strongSelf.animateMapRegion(to: points[0])
            });
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
