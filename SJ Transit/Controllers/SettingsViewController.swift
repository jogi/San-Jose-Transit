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
    case app, data, support
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var dataVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let infoDictionary = Bundle.main.infoDictionary, let version = infoDictionary["CFBundleShortVersionString"] as? String, let buildNumber = infoDictionary["CFBundleVersion"] as? String {
            self.appVersionLabel.text = "\(version) (\(buildNumber))"
        } else {
            self.appVersionLabel.text = "--"
        }
        self.dataVersionLabel.text = "\(UserDefaults.standard.integer(forKey: kDefaultsGTFSVersionKey))"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterUpdate), name: NSNotification.Name(rawValue: kDidFinishDownloadingSchedulesNotification), object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEvent(withName: "Show Updates", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let section = SettingsSection(rawValue: (indexPath as NSIndexPath).section) {
            switch section {
            case .data:
                if (indexPath as NSIndexPath).row == 1 {
                    self.checkForUpdate()
                }
            case .support:
                if (indexPath as NSIndexPath).row == 0 {
                    UIApplication.shared.openURL(URL(string: "mailto:sanjosetransit@gmail.com")!)
                } else if (indexPath as NSIndexPath).row == 1 {
                    UIApplication.shared.openURL(URL(string: "http://www.vta.org")!)
                }
            default: break
            }
        }
        
    }
    
    
    fileprivate func checkForUpdate() {
        SVProgressHUD.show(withStatus: "Checking for Updates")
        Update.checkForUpdates { (result) in
            switch (result) {
            case .success(let update):
                // delay because some times the request could come back before the progress hud is even presented
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    SVProgressHUD.dismiss()
                    if update.isNewerVersion() == true {
                        update.presentUpdateAlert(on: self) {
                            update.downloadAndUnzip(nil)
                        }
                    } else {
                        Update.presentSchedulesUpToDateAlert(on: self)
                    }
                })
            case .failure(_):
                break
            }
        }
    }
    
    
    func reloadAfterUpdate() {
        self.dataVersionLabel.text = "\(UserDefaults.standard.integer(forKey: kDefaultsGTFSVersionKey))"
        
        self.tableView.reloadData()
    }
}
