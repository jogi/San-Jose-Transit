//
//  SettingsViewController.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/3/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import Crashlytics
import SVProgressHUD

enum SettingsSection: Int {
    case App, Data, Support
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var dataVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let infoDictionary = NSBundle.mainBundle().infoDictionary, let version = infoDictionary["CFBundleShortVersionString"] as? String, let buildNumber = infoDictionary["CFBundleVersion"] as? String {
            self.appVersionLabel.text = "\(version) (\(buildNumber))"
        } else {
            self.appVersionLabel.text = "--"
        }
        self.dataVersionLabel.text = "\(NSUserDefaults.standardUserDefaults().integerForKey(kDefaultsGTFSVersionKey))"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadAfterUpdate), name: kDidFinishDownloadingSchedulesNotification, object: nil)
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
                    self.checkForUpdate()
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
    
    
    private func checkForUpdate() {
        SVProgressHUD.showWithStatus("Checking for Updates")
        Update.checkForUpdates { (result) in
            switch (result) {
            case .Success(let update):
                // delay because some times the request could come back before the progress hud is even presented
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    if update.isNewerVersion() == true {
                        update.presentUpdateAlert(on: self) {
                            update.downloadAndUnzip(nil)
                        }
                    } else {
                        Update.presentSchedulesUpToDateAlert(on: self)
                    }
                })
            case .Failure(_):
                break
            }
        }
    }
    
    
    func reloadAfterUpdate() {
        self.dataVersionLabel.text = "\(NSUserDefaults.standardUserDefaults().integerForKey(kDefaultsGTFSVersionKey))"
        
        self.tableView.reloadData()
    }
}
