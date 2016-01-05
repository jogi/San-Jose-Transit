//
//  StopRouteTimesViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class StopRouteTimesViewController: UITableViewController {
    var stopTime: StopTime?
    var data: Array<StopTime> = []
    var afterTime: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.stopTime?.stop.stopName
        self.fetchStopTimes()
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            // get all relevant tripIds
            let tripIds = Trip.trips([(self.stopTime?.route.routeId)!], activeOn: self.afterTime)
            self.data = StopTime.stopTimes(self.stopTime?.stop.stopId, routeId: self.stopTime?.route.routeId, tripIds: tripIds, afterTime: self.afterTime)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                if self.data.count > 0 {
                    self.tableView.tableFooterView = UIView(frame: CGRectZero)
                } else {
                    self.tableView.addNoDataFooterView()
                }
            });
        });
    }

    @IBAction func stopRouteTimesAction(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .Default, handler: { _ -> Void in
            self.performSegueWithIdentifier("StopRouteTimePickerSegue", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .Default, handler: { _ -> Void in
            Favorite.addFavorite(.FavoriteStop, typeId: (self.stopTime?.stop.stopId)!)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
