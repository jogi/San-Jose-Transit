//
//  Update.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 3/27/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import SVProgressHUD
import Zip

enum UpdateError: ErrorType {
    case Failed
    case JSONError
    case InvalidResponse
}

// Wrapper for errors and success value.
// Can be initialized with some T value or U error.
enum Result<T, U> {
    case Success(T)
    case Failure(U)
}

let kAgencyName = "VTA"

class Update {
    var agency: String
    var updateURL: String
    var version: Int
    
    init(agency: String, updateURL: String, version: Int) {
        self.agency = agency
        self.updateURL = updateURL
        self.version = version
    }
    
    
    class func checkForUpdates(completion: (result: Result<Update, UpdateError>) -> Void) {
        Answers.logCustomEventWithName("Check Updates", customAttributes: nil)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: "http://www.sanjosetransit.com/extras/updates-debug.json")!) { (responseData, response, error) -> Void in
            if let error = error {
                print("Update check failed: \(error)")
                completion(result: Result.Failure(UpdateError.Failed))
            } else if let responseData = responseData {
                do {
                    let responseDict = try NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments) as? [String: AnyObject]
                    if let responseDict = responseDict, let vtaUpdate = responseDict[kAgencyName] as? [String: AnyObject], let updateURL = vtaUpdate["updateURL"] as? String, let version = vtaUpdate["version"] as? NSNumber {
                        let update = Update(agency: kAgencyName, updateURL: updateURL, version: version.integerValue)
                        completion(result: Result.Success(update))
                    } else {
                        completion(result: Result.Failure(UpdateError.InvalidResponse))
                    }
                } catch {
                    print("Error parsing JSON for updates: \(error)")
                    completion(result: Result.Failure(UpdateError.JSONError))
                }
            }
        }.resume()
    }
    
    
    func isNewerVersion() -> Bool {
        let currentDataVersion = NSUserDefaults.standardUserDefaults().integerForKey(kDefaultsGTFSVersionKey)
        return self.version > currentDataVersion
    }
    
    
    func presentUpdateAlert(on viewController: UIViewController, didSelectUpdate: (Void -> Void)) {
        let alert = UIAlertController(title: "Update Available", message: "An update to the schedules is available with version \(self.version). Would you like to update?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
            didSelectUpdate()
        }))
        alert.addAction(UIAlertAction(title: "Later", style: .Cancel, handler: nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    func downloadAndUnzip(completion: (ErrorType? -> Void)?) {
        Downloader.sharedInstance.downloadFile(with: updateURL, toPath: nil, downloadProgress: { (progress) in
            SVProgressHUD.showProgress(progress)
            }, completion: { (download, error) in
                if error != nil {
                    print("Error downloading file: \(error)")
                    SVProgressHUD.showErrorWithStatus("Download Error")
                    completion?(error)
                } else {
                    SVProgressHUD.showSuccessWithStatus("Download Complete")
                    // Unzip
                    Update.unzipFileToCaches(download.destinationPath, completion: { (error) in
                        if error == nil {
                            print("Unzip successful")
                            NSNotificationCenter.defaultCenter().postNotificationName(kDidFinishDownloadingSchedulesNotification, object: nil)
                            self.updateDefaultsWithLatestVersion()
                            completion?(nil)
                        } else {
                            completion?(error)
                        }
                    })
                }
        })
    }
    
    
    func updateDefaultsWithLatestVersion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: kDefaultsFirstTimeKey)
        defaults.setInteger(self.version, forKey: kDefaultsGTFSVersionKey)
        defaults.synchronize()
    }
    
    
    class func presentSchedulesUpToDateAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Schedules up to date", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    class func unzipFileToCaches(file: String, completion: (ErrorType? -> Void)?) {
        do {
            try Zip.unzipFile(NSURL(fileURLWithPath: file), destination: NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]), overwrite: true, password: nil) { (progress) in
                if progress == 1.0 {
                    completion?(nil)
                }
            }
        } catch {
            print("Error unzipping - \(error)")
            completion?(error)
        }
    }
}