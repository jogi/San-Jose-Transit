//
//  SettingsViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

enum SettingsSection: Int {
    case App, Data, Support
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var dataVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let section = SettingsSection(rawValue: indexPath.section) {
            switch section {
            case .Data:
                if indexPath.row == 1 {
                    print("Check for Updates")
                }
            case .Support:
                if indexPath.row == 0 {
                    UIApplication.sharedApplication().openURL(NSURL(string: "mailto:sanjosetransit@gmail.com")!)
                } else if indexPath.row == 1 {
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://www.vta.org")!)
                }
            default: break
            }
        }
        
    }

}
