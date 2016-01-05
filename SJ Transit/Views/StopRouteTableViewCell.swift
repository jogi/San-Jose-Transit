//
//  StopRouteTableViewCell.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/6/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class StopRouteTableViewCell: UITableViewCell, IdentifiableCell {
    // MARK: - IBOutlets
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var tripHeadsignLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    
    // Properties
    var stopTime: StopTime! {
        didSet {
            self.routeNameLabel.text = stopTime.route.routeShortName
            self.tripHeadsignLabel.text = stopTime.trip.directionId.description + " to " + stopTime.trip.tripHeadsign
            self.timeLabel.text = stopTime.arrivalTime.humanReadableTime()
        }
    }
    
    class func cellIdentifier() -> String {
        return "StopRouteCellIdentifier"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.routeNameLabel.text = nil
        self.tripHeadsignLabel.text = nil
        self.timeLabel.text = nil
    }
}
