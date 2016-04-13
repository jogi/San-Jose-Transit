//
//  Downloader.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/3/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation

class Downloader: NSObject {
    static let sharedInstance = Downloader()
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }()
    var activeDownloads = [String: Download]()
    
    func downloadFile(with URL: String, toPath: String?, downloadProgress: ((progress: Float) -> Void), completion: ((Download, ErrorType?) -> Void)) {
        let download = Download(url: URL)
        download.downloadTask = self.session.downloadTaskWithURL(NSURL(string: URL)!)
        download.progressBlock = downloadProgress
        download.completion = completion
        download.downloadTask?.resume()
        
        self.activeDownloads[download.url] = download
    }
}


class Download {
    let url: String
    let destinationPath: String
    var downloadTask: NSURLSessionDownloadTask?
    var progressBlock: (Float -> Void)? = nil
    var completion: ((Download, ErrorType?) -> Void)? = nil
    
    init(url: String) {
        self.url = url
        self.destinationPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0].stringByAppendingString("/" + (url as NSString).lastPathComponent)
    }
}


extension Downloader: NSURLSessionDownloadDelegate {
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = self.activeDownloads[downloadUrl] {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(download.destinationPath) {
                do {
                    try fileManager.removeItemAtPath(download.destinationPath)
                } catch {
                    print("Error deleting file at path \(download.destinationPath) - \(error)")
                    download.completion?(download, error)
                }
            }
            
            do {
                try fileManager.copyItemAtURL(location, toURL: NSURL(fileURLWithPath: download.destinationPath))
            } catch {
                print("Could not copy file to disk: \(error)")
                download.completion?(download, error)
            }
            
            self.activeDownloads.removeValueForKey(downloadUrl)
            
            download.completion?(download, nil)
        }
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = self.activeDownloads[downloadUrl], progressBlock = download.progressBlock {
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            progressBlock(progress)
        }
    }
    
    
}
