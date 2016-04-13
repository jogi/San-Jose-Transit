//
//  RouteTableViewCell.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell, IdentifiableCell {
    // MARK: - IBOutlets
    @IBOutlet weak var routeShortNameLabel: UILabel!
    @IBOutlet weak var routeLongNameLabel: UILabel!
    
    var route: Route? {
        didSet {
            self.routeShortNameLabel.text = route?.routeShortName
            self.routeLongNameLabel.text = route?.routeLongName
            
            if (route?.routeType == .LightRail) {
                self.routeShortNameLabel.backgroundColor = UIColor.redColor()
            } else {
                self.routeShortNameLabel.backgroundColor = self.tintColor
            }
        }
    }
    
    class func cellIdentifier() -> String {
        return "RouteCellIdentifier"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.routeShortNameLabel.layer.cornerRadius = 4.0
        self.routeShortNameLabel.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.routeShortNameLabel.text = nil
        self.routeLongNameLabel.text = nil
    }
}
