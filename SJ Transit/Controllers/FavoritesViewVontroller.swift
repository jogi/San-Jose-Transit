//
//  FavoritesViewVontroller.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class FavoritesViewVontroller: UITableViewController {
    var favorites = [[Favorite]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moveFavoritesIfRequired()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchFavorites()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.favorites.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let outerCell: UITableViewCell!
        let favorite = self.favorites[indexPath.section][indexPath.row]
        
        if favorite.type == .FavoriteRoute {
            let cell = tableView.dequeueIdentifiableCell(RouteTableViewCell.self, forIndexPath: indexPath)
            cell.route = favorite.favorite as? Route
            outerCell = cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesStopCellIdentifier", forIndexPath: indexPath)
            let stop = favorite.favorite as? Stop
            cell.textLabel?.text = stop?.stopName
            cell.detailTextLabel?.text = stop?.routes
            outerCell = cell
        }

        return outerCell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let favorite = self.favorites[indexPath.section][indexPath.row]
        if favorite.type == .FavoriteRoute {
            let viewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RouteDetailViewController") as? RouteDetailViewController
            viewController?.route = favorite.favorite as? Route
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            let stopRouteController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StopRouteViewController") as! StopRouteViewController
            stopRouteController.stop = favorite.favorite as? Stop
            self.navigationController?.pushViewController(stopRouteController, animated: true)
        }
    }


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            Favorite.deleteFavorite(self.favorites[indexPath.section][indexPath.row].favoriteId)
            self.favorites[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            if self.favorites.count == 0 {
                tableView.addNoDataFooterView("No favorites.")
            }
        }
    }

    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        var tempFavorites = self.favorites[fromIndexPath.section]
        let tempObject = tempFavorites[fromIndexPath.row]
        tempFavorites.removeAtIndex(fromIndexPath.row)
        tempFavorites.insert(tempObject, atIndex: toIndexPath.row)
        self.favorites[fromIndexPath.section] = tempFavorites
        
        for (index, element) in tempFavorites.enumerate() {
            element.sortOrder = index
        }
        
        Favorite.updateFavorites(tempFavorites)
    }
    
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = tableView.numberOfRowsInSection(sourceIndexPath.section) - 1
            }
            
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        
        return proposedDestinationIndexPath
    }
    
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func fetchFavorites() {
        self.tableView.addLoadingFooterView()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.favorites = Favorite.favorites()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                if self.favorites.count > 0 {
                    self.tableView.tableFooterView = UIView(frame: CGRectZero)
                } else {
                    self.tableView.addNoDataFooterView("No favorites.")
                }
            });
        });
    }
    
    
    func moveFavoritesIfRequired() {
        let bundleFavoritesPath = NSBundle.mainBundle().pathForResource("favorites", ofType: "db")!
        let documentsFavoritesPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/favorites.db")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(documentsFavoritesPath) {
            do {
                try NSFileManager.defaultManager().copyItemAtPath(bundleFavoritesPath, toPath: documentsFavoritesPath)
            } catch {
                print("Couldn't copy favorites db to Documents: \(error)")
            }
        }
    }
}
