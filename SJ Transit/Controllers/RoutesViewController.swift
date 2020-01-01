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
    var routes: [Route] = []
    var filteredRoutes: [Route] = []
    var searchController: UISearchController!
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.definesPresentationContext = true
        self.searchController.delegate = self
        self.navigationItem.searchController = self.searchController
        
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
        return self.isFiltering ? self.filteredRoutes.count : self.routes.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(RouteTableViewCell.self, forIndexPath: indexPath)

        cell.route = self.isFiltering ? self.filteredRoutes[indexPath.row] : self.routes[indexPath.row]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RouteDetailViewController") as? RouteDetailViewController
        viewController?.route = self.isFiltering ? self.filteredRoutes[indexPath.row] : self.routes[indexPath.row]
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }

    
    // MARK: - Controller methods
    
    func fetchRoutes() {
        self.routes = Route.routes()
        self.tableView.reloadData()
    }
    
    @objc func reloadAfterUpdate() {
        // remove the no schedule view
        self.removeNoScheduleView()
        
        // reload data
        self.fetchRoutes()
    }
}

extension RoutesViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text?.lowercased(), searchString.count > 0 else {
            return
        }
        
        self.filteredRoutes = self.routes.filter {
            $0.routeLongName.lowercased().contains(searchString) || $0.routeShortName.lowercased().contains(searchString)
        }
        
        self.tableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.tableView.reloadData()
    }
}
