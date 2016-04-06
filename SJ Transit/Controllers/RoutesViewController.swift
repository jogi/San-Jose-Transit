//
//  RoutesViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite

class RoutesViewController: UITableViewController {
    var routes: Array<Route>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNoScheduleViewIfRequired()
        self.fetchRoutes()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadAfterUpdate), name: kDidFinishDownloadingSchedulesNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.routes.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(RouteTableViewCell.self, forIndexPath: indexPath)

        cell.route = self.routes[indexPath.row]

        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let viewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RouteDetailViewController") as? RouteDetailViewController
        viewController?.route = self.routes[indexPath.row]
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }

    
    // MARK: - Controller methods
    
    func fetchRoutes() {
        self.routes = Route.routes()
        self.tableView.reloadData()
    }
    
    
    func reloadAfterUpdate() {
        // remove the no schedule view
        self.removeNoScheduleView()
        
        // reload data
        self.fetchRoutes()
    }
}
