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
import SVProgressHUD

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Vars
    var locationManager: CLLocationManager!
    var stops: Array<Stop>?
    var hasAcquiredUserLocaion: Bool = false
    
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
        
        self.fetchStops()
    }
    

    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if self.hasAcquiredUserLocaion == false {
            self.hasAcquiredUserLocaion = true
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        }
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
        let stop = view.annotation as? Stop
        let stopRouteController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteViewController") as! StopRouteViewController
        stopRouteController.stop = stop
        self.navigationController?.pushViewController(stopRouteController, animated: true)
    }

    
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.show()
        
        let searchRequest = MKLocalSearchRequest.init()
        searchRequest.naturalLanguageQuery = searchBar.text
        searchRequest.region = self.mapView.region
        
        let localSearch = MKLocalSearch.init(request: searchRequest)
        localSearch.startWithCompletionHandler { (response, error) -> Void in
            guard let response = response else {
                NSLog("Search error: \(error)")
                SVProgressHUD.showErrorWithStatus("Try Again")
                return
            }
            
            SVProgressHUD.dismiss()
            if response.mapItems.count > 0 {
                let firstMapItem = response.mapItems[0] as MKMapItem!
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance((firstMapItem.placemark.location?.coordinate)!, 1000, 1000), animated: true)
            }
        }
    }
    
    
    // MARK: - Controller methods
    func fetchStops() {
        self.stops = Stop.stops()
        if (self.stops != nil) {
            self.mapView.addAnnotations(self.stops!)
        }
    }
}
