//
//  StopRouteViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/4/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class StopRouteViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var routesLabel: UILabel!
    
    var stop: Stop?
    var data: Array<StopTime> = []
    var afterTime: NSDate = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Departures"
        self.stopNameLabel.text = self.stop?.stopName
        self.routesLabel.text = self.stop?.routes
        
        self.fetchStopTimes()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(StopRouteTableViewCell.self, forIndexPath: indexPath)
        cell.stopTime = self.data[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let stopTime = self.data[indexPath.row]
        stopTime.stop.stopId = self.stop?.stopId
        stopTime.stop.stopName = self.stop?.stopName
        
        let stopRouteTimeController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteTimesViewController") as! StopRouteTimesViewController
        stopRouteTimeController.stopTime = stopTime
        stopRouteTimeController.afterTime = self.afterTime
        
        self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
    }
    

    func fetchStopTimes() {
        // get all relevant tripIds
        self.tableView.addLoadingFooterView()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let tripIds = Trip.trips((strongSelf.stop!.routes?.componentsSeparatedByString(", "))!, activeOn: strongSelf.afterTime)
            strongSelf.data = StopTime.stopTimes(strongSelf.stop!.stopId, afterTime: strongSelf.afterTime, tripIds: tripIds)
            
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
    
    @IBAction func stopRouteAction(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .Default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.performSegueWithIdentifier("StopRouteDatePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.FavoriteStop, typeId: (self.stop?.stopId)!) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.deleteFavorite(.FavoriteStop, typeId: (strongSelf.stop?.stopId)!)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .Default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.addFavorite(.FavoriteStop, typeId: (strongSelf.stop?.stopId)!)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StopRouteDatePickerSegue" {
            let viewController = segue.destinationViewController as! DateTimePickerViewController
            viewController.onDateSelected = { selectedDate in
                self.afterTime = selectedDate
                self.fetchStopTimes()
            }
        }
    }
}
