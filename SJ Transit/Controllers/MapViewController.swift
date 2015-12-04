//
//  MapViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Vars
    var locationManager: CLLocationManager!
    var stops: Array<Stop>?
    
    // MARK: - IBActions
    @IBAction func locateUser(sender: UIBarButtonItem) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    }
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.locationManager = CLLocationManager.init()
        self.locationManager.requestWhenInUseAuthorization()
        
        self.navigationController?.navigationBar.topItem?.titleView = self.locationSearchBar
        
        self.fetchStops()
    }
    

    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView?
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("stopPin") as? MKPinAnnotationView
            
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "stopPin")
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = mapView.tintColor
                annotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stop = view.annotation as? Stop
        print("Callout accessory tapped for \(stop?.stopId), \(stop?.stopName))")
    }

    
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchRequest = MKLocalSearchRequest.init()
        searchRequest.naturalLanguageQuery = searchBar.text
        searchRequest.region = self.mapView.region
        
        let localSearch = MKLocalSearch.init(request: searchRequest)
        localSearch.startWithCompletionHandler { (response, error) -> Void in
            guard let response = response else {
                NSLog("Search error: \(error)")
                return
            }
            
            if response.mapItems.count > 0 {
                let firstMapItem = response.mapItems[0] as MKMapItem!
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance((firstMapItem.placemark.location?.coordinate)!, 1000, 1000), animated: true)
            }
        }
    }
    
    
    // MARK: - Controller methods
    func fetchStops() {
        self.stops = Stop.fetchAllStops()
        if (self.stops != nil) {
            self.mapView.addAnnotations(self.stops!)
        }
    }
}
