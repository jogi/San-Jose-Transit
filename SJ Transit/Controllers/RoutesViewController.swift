//
//  RoutesViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite
import Crashlytics

class RoutesViewController: UITableViewController {
    var routes: Array<Route>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.addNoScheduleViewIfRequired()
        self.fetchRoutes()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterUpdate), name: NSNotification.Name(rawValue: kDidFinishDownloadingSchedulesNotification), object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Routes", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.routes.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(RouteTableViewCell.self, forIndexPath: indexPath)

        cell.route = self.routes[(indexPath as NSIndexPath).row]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RouteDetailViewController") as? RouteDetailViewController
        viewController?.route = self.routes[(indexPath as NSIndexPath).row]
        
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
