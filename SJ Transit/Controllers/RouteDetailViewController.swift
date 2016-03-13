//
//  RouteDetailViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class RouteDetailViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var directionSegment: UISegmentedControl!
    @IBOutlet weak var shortNameLabel: UILabel!
    @IBOutlet weak var longNameLabel: UILabel!
    
    var route: Route!
    var times: Array<StopTime> = Array<StopTime>()
    var afterTime: NSDate = NSDate()
    var tripId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shortNameLabel.text = self.route.routeShortName
        self.longNameLabel.text = self.route.routeLongName
        
        self.shortNameLabel.layer.cornerRadius = 4.0
        self.shortNameLabel.layer.masksToBounds = true
        
        self.tableView.registerIdentifiableCell(TripStopTableViewCell.self)
        
        self.fetchTrip()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.times.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(TripStopTableViewCell.self, forIndexPath: indexPath)

        // Configure the cell...
        cell.stopTime = self.times[indexPath.row]
        cell.topLineView.hidden = indexPath.row == 0
        cell.bottomLineView.hidden = indexPath.row == (self.times.count - 1)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let stopTime = self.times[indexPath.row]
        stopTime.route.routeId = self.route.routeId
        
        let stopRouteTimeController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteTimesViewController") as! StopRouteTimesViewController
        stopRouteTimeController.stopTime = stopTime
        
        self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
    }
    
    
    func fetchTrip() {
        self.tableView.addLoadingFooterView()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            // get the first trip
            strongSelf.tripId = StopTime.trip(strongSelf.route?.routeId, directionId: Direction(rawValue: strongSelf.directionSegment.selectedSegmentIndex), afterTime: strongSelf.afterTime)
            
            if let tripId = strongSelf.tripId {
                strongSelf.times = StopTime.stopTimes(tripId)
            } else {
                strongSelf.times = []
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                strongSelf.tableView.reloadData()
                if strongSelf.times.count > 0 {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRectZero)
                } else {
                    print("No trips found for route: \(strongSelf.route?.routeId), direction: \(Direction(rawValue: strongSelf.directionSegment.selectedSegmentIndex)), afterTime: \(strongSelf.afterTime)")
                    strongSelf.tableView.addNoDataFooterView()
                }
            });
        });
    }
    
    // MARK: - IBActions
    @IBAction func routeAction(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if self.times.count > 0 {
            alertController.addAction(UIAlertAction(title: "Route Map", style: .Default, handler: { _ -> Void in
                let viewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RouteMapViewController") as? RouteMapViewController
                viewController?.times = self.times
                viewController?.tripId = self.tripId
                
                self.navigationController?.pushViewController(viewController!, animated: true)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .Default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.performSegueWithIdentifier("RouteTimePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.FavoriteRoute, typeId: self.route.routeId) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.deleteFavorite(.FavoriteRoute, typeId: strongSelf.route.routeId)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.addFavorite(.FavoriteRoute, typeId: strongSelf.route.routeId)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func directionChanged(sender: UISegmentedControl) {
        self.times = []
        self.tableView.reloadData()
        self.fetchTrip()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RouteTimePickerSegue" {
            let viewController = segue.destinationViewController as! DateTimePickerViewController
            viewController.onDateSelected = { selectedDate in
                self.afterTime = selectedDate
                
                dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.times = []
                    strongSelf.tableView.reloadData()
                    strongSelf.fetchTrip()
                });
            }
        }
    }
}
