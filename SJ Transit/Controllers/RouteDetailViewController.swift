//
//  RouteDetailViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import GTFSModel

class RouteDetailViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var directionSegment: UISegmentedControl!
    @IBOutlet weak var shortNameLabel: UILabel!
    @IBOutlet weak var longNameLabel: UILabel!
    
    var route: Route!
    var times: [TripStopSummary] = []
    var afterTime: Date = Date()
    var tripId: String?
    var selectedDirectionIdentifier: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shortNameLabel.text = self.route.shortName
        self.longNameLabel.text = self.route.longName
        
        self.shortNameLabel.layer.cornerRadius = 4.0
        self.shortNameLabel.layer.masksToBounds = true
        
        self.tableView.registerIdentifiableCell(TripStopTableViewCell.self)
        
        self.fetchTrip()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.times.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(TripStopTableViewCell.self, forIndexPath: indexPath)

        // Configure the cell...
        cell.stopTime = self.times[(indexPath as NSIndexPath).row]
        cell.topLineView.isHidden = (indexPath as NSIndexPath).row == 0
        cell.bottomLineView.isHidden = (indexPath as NSIndexPath).row == (self.times.count - 1)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stopTime = self.times[(indexPath as NSIndexPath).row]
        let stopRouteSummary = StopRouteSummary(
            arrivalTime: stopTime.arrivalTime,
            routeIdentifier: self.route.identifier,
            routeShortName: self.route.shortName,
            routeLongName: self.route.longName,
            tripIdentifier: self.tripId ?? "",
            tripHeadsign: nil,
            directionIdentifier: selectedDirectionIdentifier,
            shapeIdentifier: nil,
            stopIdentifier: stopTime.stopIdentifier,
            stopName: stopTime.stopName,
            stopLatitude: stopTime.stopLatitude,
            stopLongitude: stopTime.stopLongitude,
            stopRoutes: stopTime.stopRoutes
        )
        
        let stopRouteTimeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteTimesViewController") as! StopRouteTimesViewController
        stopRouteTimeController.stopTime = stopRouteSummary
        stopRouteTimeController.afterTime = self.afterTime
        
        self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
    }
    
    
    func fetchTrip() {
        self.tableView.addLoadingFooterView()
        let selectedDirection = self.directionSegment.selectedSegmentIndex
        self.selectedDirectionIdentifier = selectedDirection
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            // get the first trip
            strongSelf.tripId = StopTime.nextTripIdentifier(routeIdentifier: strongSelf.route.identifier, directionIdentifier: selectedDirection, afterTime: strongSelf.afterTime)
            
            if let tripId = strongSelf.tripId {
                strongSelf.times = StopTime.tripStopTimes(tripIdentifier: tripId)
            } else {
                strongSelf.times = []
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.tableView.reloadData()
                if strongSelf.times.count > 0 {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRect.zero)
                } else {
                    print("No trips found for route: \(strongSelf.route.identifier), direction: \(selectedDirection), afterTime: \(strongSelf.afterTime)")
                    strongSelf.tableView.addNoDataFooterView()
                }
            });
        });
    }
    
    // MARK: - IBActions
    @IBAction func routeAction(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if self.times.count > 0 {
            alertController.addAction(UIAlertAction(title: "Route Map", style: .default, handler: { _ -> Void in
                let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RouteMapViewController") as? RouteMapViewController
                viewController?.times = self.times
                viewController?.tripId = self.tripId
                
                self.navigationController?.pushViewController(viewController!, animated: true)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.performSegue(withIdentifier: "RouteTimePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.favoriteRoute, typeId: self.route.identifier) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.deleteFavorite(.favoriteRoute, typeId: strongSelf.route.identifier)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.addFavorite(.favoriteRoute, typeId: strongSelf.route.identifier)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        self.times = []
        self.tableView.reloadData()
        self.fetchTrip()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RouteTimePickerSegue" {
            let viewController = segue.destination as! DateTimePickerViewController
            viewController.onDateSelected = { selectedDate in
                self.afterTime = selectedDate
                
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.times = []
                    strongSelf.tableView.reloadData()
                    strongSelf.fetchTrip()
                });
            }
        }
    }
}
