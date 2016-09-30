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
    var afterTime: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.stopTime?.stop.stopName
        self.fetchStopTimes()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Stop Route Times", customAttributes: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(StopRouteTimeTableViewCell.self, forIndexPath: indexPath)

        // Configure the cell...
        cell.stopTime = self.data[(indexPath as NSIndexPath).row]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tripDetailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TripDetailViewController") as! TripDetailViewController
        let aStopTime = self.data[(indexPath as NSIndexPath).row]
        aStopTime.stop = self.stopTime!.stop
        tripDetailController.stopTime = self.data[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(tripDetailController, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StopRouteTimePickerSegue" {
            let viewController = segue.destination as! DateTimePickerViewController
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
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            // get all relevant tripIds
            let tripIds = Trip.trips([(strongSelf.stopTime?.route.routeId)!], activeOn: strongSelf.afterTime)
            strongSelf.data = StopTime.stopTimes(strongSelf.stopTime?.stop.stopId, routeId: strongSelf.stopTime?.route.routeId, tripIds: tripIds, afterTime: strongSelf.afterTime)
            
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.tableView.reloadData()
                if strongSelf.data.count > 0 {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRect.zero)
                } else {
                    strongSelf.tableView.addNoDataFooterView()
                }
            });
        });
    }

    @IBAction func stopRouteTimesAction(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "StopRouteTimePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.favoriteStop, typeId: (self.stopTime?.stop.stopId)!) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                Favorite.deleteFavorite(.favoriteStop, typeId: (strongSelf.stopTime?.stop.stopId)!)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                Favorite.addFavorite(.favoriteStop, typeId: (strongSelf.stopTime?.stop.stopId)!)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
