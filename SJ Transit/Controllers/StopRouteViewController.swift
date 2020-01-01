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
    var afterTime: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Departures"
        self.stopNameLabel.text = self.stop?.stopName
        self.routesLabel.text = self.stop?.routes
        
        self.fetchStopTimes()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(StopRouteTableViewCell.self, forIndexPath: indexPath)
        cell.stopTime = self.data[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stopTime = self.data[(indexPath as NSIndexPath).row]
        stopTime.stop.stopId = self.stop?.stopId
        stopTime.stop.stopName = self.stop?.stopName
        
        let stopRouteTimeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteTimesViewController") as! StopRouteTimesViewController
        stopRouteTimeController.stopTime = stopTime
        stopRouteTimeController.afterTime = self.afterTime
        
        self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
    }
    

    func fetchStopTimes() {
        // get all relevant tripIds
        self.tableView.addLoadingFooterView()
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            
            let tripIds = Trip.trips((strongSelf.stop!.routes?.components(separatedBy: ", "))!, activeOn: strongSelf.afterTime)
            strongSelf.data = StopTime.stopTimes(strongSelf.stop!.stopId, afterTime: strongSelf.afterTime, tripIds: tripIds)
            
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
    
    @IBAction func stopRouteAction(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Departure Time", style: .default, handler: { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.performSegue(withIdentifier: "StopRouteDatePickerSegue", sender: strongSelf)
        }))
        if Favorite.isFavorite(.favoriteStop, typeId: (self.stop?.stopId)!) {
            alertController.addAction(UIAlertAction(title: "Remove As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.deleteFavorite(.favoriteStop, typeId: (strongSelf.stop?.stopId)!)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Add As Favorite", style: .default, handler: { [weak self] _ -> Void in
                guard let strongSelf = self else { return }
                
                Favorite.addFavorite(.favoriteStop, typeId: (strongSelf.stop?.stopId)!)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StopRouteDatePickerSegue" {
            let viewController = segue.destination as! DateTimePickerViewController
            viewController.onDateSelected = { selectedDate in
                self.afterTime = selectedDate
                self.fetchStopTimes()
            }
        }
    }
}
