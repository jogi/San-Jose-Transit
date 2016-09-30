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
import Crashlytics

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Vars
    var locationManager: CLLocationManager!
    var stops: Array<Stop>?
    var hasAcquiredUserLocaion: Bool = false
    
    // MARK: - IBActions
    @IBAction func locateUser(_ sender: UIBarButtonItem) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    }
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        
        self.fetchStops()
        _ = self.addNoScheduleViewIfRequired()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterUpdate), name: NSNotification.Name(rawValue: kDidFinishDownloadingSchedulesNotification), object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Map", customAttributes: nil)
    }
    

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.hasAcquiredUserLocaion == false {
            self.hasAcquiredUserLocaion = true
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        }
    }
    
    
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
                disclosureButton.setImage(UIImage(named: "right-arrow"), for: UIControlState()) // yup, annotation views are stupid, so try to trick it
                annotationView?.rightCalloutAccessoryView = disclosureButton
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stop = view.annotation as? Stop
        let stopRouteController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteViewController") as! StopRouteViewController
        stopRouteController.stop = stop
        self.navigationController?.pushViewController(stopRouteController, animated: true)
    }

    
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.show()
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        searchRequest.region = self.mapView.region
        
        Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) -> Void in
            guard let response = response else {
                NSLog("Search error: \(error)")
                SVProgressHUD.showError(withStatus: "Try Again")
                return
            }
            
            SVProgressHUD.dismiss()
            if response.mapItems.count > 0 {
                let firstMapItem = response.mapItems[0] as MKMapItem!
                self.mapView.setRegion(MKCoordinateRegionMakeWithDistance((firstMapItem?.placemark.location?.coordinate)!, 1000, 1000), animated: true)
            }
        }
    }
    
    
    // MARK: - Controller methods
    func fetchStops() {
        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.stops = Stop.stops()
            if (strongSelf.stops != nil) {
                DispatchQueue.main.async(execute: { () -> Void in
                    strongSelf.mapView.addAnnotations(strongSelf.stops!)
                });
            }
        }
    }
    
    func reloadAfterUpdate() {
        // remove the no schedule view
        self.removeNoScheduleView()
        
        // reload data
        self.fetchStops()
    }
}
