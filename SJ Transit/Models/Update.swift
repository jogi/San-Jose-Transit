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

enum UpdateError: Error {
    case failed
    case jsonError
    case invalidResponse
}

// Wrapper for errors and success value.
// Can be initialized with some T value or U error.
enum Result<T, U> {
    case success(T)
    case failure(U)
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
    
    
    class func checkForUpdates(_ completion: @escaping (_ result: Result<Update, UpdateError>) -> Void) {
        Answers.logCustomEvent(withName: "Check Updates", customAttributes: nil)
        
        URLCache.shared.removeAllCachedResponses()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfiguration.urlCache = nil
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: URL(string: "http://www.sanjosetransit.com/extras/updates-debug.json")!, completionHandler: { (responseData, response, error) -> Void in
            if let error = error {
                print("Update check failed: \(error)")
                completion(Result.failure(UpdateError.failed))
            } else if let responseData = responseData {
                do {
                    let responseDict = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: AnyObject]
                    if let responseDict = responseDict, let vtaUpdate = responseDict[kAgencyName] as? [String: AnyObject], let updateURL = vtaUpdate["updateURL"] as? String, let version = vtaUpdate["version"] as? NSNumber {
                        let update = Update(agency: kAgencyName, updateURL: updateURL, version: version.intValue)
                        completion(Result.success(update))
                    } else {
                        completion(Result.failure(UpdateError.invalidResponse))
                    }
                } catch {
                    print("Error parsing JSON for updates: \(error)")
                    completion(Result.failure(UpdateError.jsonError))
                }
            }
        }) .resume()
    }
    
    
    func isNewerVersion() -> Bool {
        let currentDataVersion = UserDefaults.standard.integer(forKey: kDefaultsGTFSVersionKey)
        return self.version > currentDataVersion
    }
    
    
    func presentUpdateAlert(on viewController: UIViewController, didSelectUpdate: @escaping ((Void) -> Void)) {
        let alert = UIAlertController(title: "Update Available", message: "An update to the schedules is available with version \(self.version). Would you like to update?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            didSelectUpdate()
        }))
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
        
        DispatchQueue.main.async(execute: {
            viewController.present(alert, animated: true, completion: nil)
        })
    }
    
    
    func downloadAndUnzip(_ completion: ((Error?) -> Void)?) {
        Downloader.sharedInstance.downloadFile(with: updateURL, toPath: nil, downloadProgress: { (progress) in
            SVProgressHUD.showProgress(progress)
            }, completion: { (download, error) in
                if error != nil {
                    print("Error downloading file: \(error)")
                    SVProgressHUD.showError(withStatus: "Download Error")
                    completion?(error)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Download Complete")
                    // Unzip
                    Update.unzipFileToCaches(download.destinationPath, completion: { (error) in
                        if error == nil {
                            print("Unzip successful")
                            defer {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: kDidFinishDownloadingSchedulesNotification), object: nil)
                                self.updateDefaultsWithLatestVersion()
                                completion?(nil)
                            }
                            // delete the zip file
                            do {
                                try FileManager.default.removeItem(atPath: download.destinationPath)
                            } catch {
                                print("Error deleting the temp downloaded file: \(error)")
                            }
                        } else {
                            completion?(error)
                        }
                    })
                }
        })
    }
    
    
    func updateDefaultsWithLatestVersion() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: kDefaultsFirstTimeKey)
        defaults.set(self.version, forKey: kDefaultsGTFSVersionKey)
        defaults.synchronize()
    }
    
    
    class func presentSchedulesUpToDateAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Schedules up to date", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        DispatchQueue.main.async(execute: {
            viewController.present(alert, animated: true, completion: nil)
        })
    }
    
    
    class func unzipFileToCaches(_ file: String, completion: ((Error?) -> Void)?) {
        do {
            try Zip.unzipFile(URL(fileURLWithPath: file), destination: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]), overwrite: true, password: nil) { (progress) in
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
