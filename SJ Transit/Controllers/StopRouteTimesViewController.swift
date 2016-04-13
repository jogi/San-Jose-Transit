//
//  StopRouteTimesViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import Crashlytics

class StopRouteTimesViewController: UITableViewController {
    var stopTime: StopTime?
    var data: Array<StopTime> = []
    var afterTime: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.stopTime?.stop.stopName
        self.fetchStopTimes()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEventWithName("Show Stop Route Times", customAttributes: nil)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(StopRouteTimeTableViewCell.self, forIndexPath: indexPath)

        // Configure the cell...
        cell.stopTime = self.data[indexPath.row]

        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let tripDetailController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TripDetailViewController") as! TripDetailViewController
        let aStopTime = self.data[indexPath.row]
        aStopTime.stop = self.stopTime!.stop
        tripDetailController.stopTime = self.data[indexPath.row]
        self.navigationController?.pushViewController(tripDetailController, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StopRouteTimePickerSegue" {
            let viewController = segue.destinationViewController as! DateTimePickerViewController
            viewController.onDateSelected = { selectedDate in
                self.afterTime = selectedDate
                self.data = []
                self.tableView.reloadData()
                self.fetchStopTimes()
            }
        }
    }
    
    
    func fetchStopTimes() {
        self.tableView.addLoadingFooterView()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            // get all relevant tripIds
            let tripIds = Trip.trips([(strongSelf.stopTime?.route.routeId)!], activeOn: strongSelf.afterTime)
            strongSelf.data = StopTime.stopTimes(strongSelf.stopTime?.stop.stopId, routeId: strongSelf.stopTime?.route.routeId, tripIds: tripIds, afterTime: strongSelf.afterTime)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                strongSelf.tableView.reloadData()
                if strongSelf.data.count > 0 {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRectZero)
                } else {
                    strongSelf.tableView.addNoDataFooterView()
                }
            });
        });
    }

    @IBAction func stopRouteTimesAction(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .Default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            strongSelf.performSegueWithIdentifier("StopRouteTimePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.FavoriteStop, typeId: (self.stopTime?.stop.stopId)!) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                Favorite.deleteFavorite(.FavoriteStop, typeId: (strongSelf.stopTime?.stop.stopId)!)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                Favorite.addFavorite(.FavoriteStop, typeId: (strongSelf.stopTime?.stop.stopId)!)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
