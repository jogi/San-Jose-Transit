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
    }
    

    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
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
}
