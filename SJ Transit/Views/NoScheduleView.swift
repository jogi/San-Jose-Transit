//
//  NoScheduleView.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/2/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class NoScheduleView: UIView {
    
    @IBAction func download(_ sender: AnyObject) {
        // first get the latest Updates URL
        SVProgressHUD.show(withStatus: "Checking for Updates")
        Update.checkForUpdates { (result) in
            switch (result) {
            case .success(let update):
                update.downloadAndUnzip({ (error) in
                    if error != nil {
                        print("Error downloading update")
                    }
                })
            case .failure(_):
                print("Unable to check for updates.")
            }
        }
    }
}


extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
