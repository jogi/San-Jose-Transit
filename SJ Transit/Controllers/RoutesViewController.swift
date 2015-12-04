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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.fetchRoutes()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutesCellIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = String(format: "%@ %@", self.routes[indexPath.row].routeShortName!, self.routes[indexPath.row].routeLongName!)

        return cell
    }

    
    // MARK: - Controller methods
    
    func fetchRoutes() {
        self.routes = Route.fetchAllRoutes()
        self.tableView.reloadData()
    }
}
