//
//  FavoritesViewVontroller.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import Crashlytics

class FavoritesViewVontroller: UITableViewController {
    var favorites = [[Favorite]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = self.addNoScheduleViewIfRequired()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterUpdate), name: NSNotification.Name(rawValue: kDidFinishDownloadingSchedulesNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchFavorites()
        Answers.logCustomEvent(withName: "Show Favorites", customAttributes: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.favorites.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let outerCell: UITableViewCell!
        let favorite = self.favorites[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        if favorite.type == .favoriteRoute {
            let cell = tableView.dequeueIdentifiableCell(RouteTableViewCell.self, forIndexPath: indexPath)
            cell.route = favorite.favorite as? Route
            outerCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesStopCellIdentifier", for: indexPath)
            let stop = favorite.favorite as? Stop
            cell.textLabel?.text = stop?.stopName
            cell.detailTextLabel?.text = stop?.routes
            outerCell = cell
        }

        return outerCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favorite = self.favorites[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if favorite.type == .favoriteRoute {
            let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RouteDetailViewController") as? RouteDetailViewController
            viewController?.route = favorite.favorite as? Route
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            let stopRouteController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteViewController") as! StopRouteViewController
            stopRouteController.stop = favorite.favorite as? Stop
            self.navigationController?.pushViewController(stopRouteController, animated: true)
        }
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            Favorite.deleteFavorite(self.favorites[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].favoriteId)
            self.favorites[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            if self.favorites.count == 0 {
                tableView.addNoDataFooterView("No favorites.")
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        var tempFavorites = self.favorites[(fromIndexPath as NSIndexPath).section]
        let tempObject = tempFavorites[(fromIndexPath as NSIndexPath).row]
        tempFavorites.remove(at: (fromIndexPath as NSIndexPath).row)
        tempFavorites.insert(tempObject, at: (toIndexPath as NSIndexPath).row)
        self.favorites[(fromIndexPath as NSIndexPath).section] = tempFavorites
        
        for (index, element) in tempFavorites.enumerated() {
            element.sortOrder = index
        }
        
        Favorite.updateFavorites(tempFavorites)
    }
    
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (sourceIndexPath as NSIndexPath).section != (proposedDestinationIndexPath as NSIndexPath).section {
            var row = 0
            if (sourceIndexPath as NSIndexPath).section < (proposedDestinationIndexPath as NSIndexPath).section {
                row = tableView.numberOfRows(inSection: (sourceIndexPath as NSIndexPath).section) - 1
            }
            
            return IndexPath(row: row, section: (sourceIndexPath as NSIndexPath).section)
        }
        
        return proposedDestinationIndexPath
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func fetchFavorites() {
        self.tableView.addLoadingFooterView()
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.favorites = Favorite.favorites()
            
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.tableView.reloadData()
                if strongSelf.favorites.count > 0 {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRect.zero)
                } else {
                    strongSelf.tableView.addNoDataFooterView("No favorites.")
                }
            });
        });
    }
    
    
    func reloadAfterUpdate() {
        // remove the no schedule view
        self.removeNoScheduleView()
        
        // reload data
        self.fetchFavorites()
    }
}
