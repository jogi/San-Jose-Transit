//
//  UITableView+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/10/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

extension UITableView {
    func addLoadingFooterView() {
        let footerView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, 44))
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.center = footerView.center
        activityIndicator.startAnimating()
        
        footerView.addSubview(activityIndicator)
        
        self.tableFooterView = footerView
    }
    
    func addNoDataFooterView(noDataText: String = "No trips found.") {
        let footerView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, 120))
        let noDataLabel = UILabel(frame: footerView.frame)
        noDataLabel.text = noDataText
        noDataLabel.textAlignment = .Center
        noDataLabel.textColor = UIColor.lightGrayColor()
        footerView.addSubview(noDataLabel)
        
        self.tableFooterView = footerView
    }
}