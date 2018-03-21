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
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = footerView.center
        activityIndicator.startAnimating()
        
        footerView.addSubview(activityIndicator)
        
        self.tableFooterView = footerView
    }
    
    func addNoDataFooterView(_ noDataText: String = "No trips found.") {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 120))
        let noDataLabel = UILabel(frame: footerView.frame)
        noDataLabel.text = noDataText
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = UIColor.lightGray
        footerView.addSubview(noDataLabel)
        
        self.tableFooterView = footerView
    }
}
