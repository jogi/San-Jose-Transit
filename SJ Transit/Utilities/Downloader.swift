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
    
    lazy var session: Foundation.URLSession = {
        return Foundation.URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: OperationQueue.main)
    }()
    var activeDownloads = [String: Download]()
    
    func downloadFile(with URL: String, toPath: String?, downloadProgress: @escaping ((_ progress: Float) -> Void), completion: @escaping ((Download, Error?) -> Void)) {
        let download = Download(url: URL)
        download.downloadTask = self.session.downloadTask(with: Foundation.URL(string: URL)!)
        download.progressBlock = downloadProgress
        download.completion = completion
        download.downloadTask?.resume()
        
        self.activeDownloads[download.url] = download
    }
}


class Download {
    let url: String
    let destinationPath: String
    var downloadTask: URLSessionDownloadTask?
    var progressBlock: ((Float) -> Void)? = nil
    var completion: ((Download, Error?) -> Void)? = nil
    
    init(url: String) {
        self.url = url
        self.destinationPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + ("/" + (url as NSString).lastPathComponent)
    }
}


extension Downloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString, let download = self.activeDownloads[downloadUrl] {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: download.destinationPath) {
                do {
                    try fileManager.removeItem(atPath: download.destinationPath)
                } catch {
                    print("Error deleting file at path \(download.destinationPath) - \(error)")
                    download.completion?(download, error)
                }
            }
            
            do {
                try fileManager.copyItem(at: location, to: URL(fileURLWithPath: download.destinationPath))
            } catch {
                print("Could not copy file to disk: \(error)")
                download.completion?(download, error)
            }
            
            self.activeDownloads.removeValue(forKey: downloadUrl)
            
            download.completion?(download, nil)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString, let download = self.activeDownloads[downloadUrl], let progressBlock = download.progressBlock {
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            progressBlock(progress)
        }
    }
    
    
}
