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
    @IBOutlet weak var fullTimeLabel: UILabel!
    
    // Properties
    var stopTime: StopTime! {
        didSet {
            self.routeNameLabel.text = stopTime.route.routeShortName
            self.tripHeadsignLabel.text = stopTime.trip.directionId.description + " to " + stopTime.trip.tripHeadsign
            let minutesFromNow = stopTime.arrivalTime.minutesFromNow()
            if minutesFromNow >= 0 {
                self.timeLabel.text = "\(minutesFromNow)"
                self.timeLabel.hidden = false
                self.minutesLabel.hidden = false
                self.fullTimeLabel.hidden = true
            } else {
                self.fullTimeLabel.text = stopTime.arrivalTime.timeAsString
                self.timeLabel.hidden = true
                self.minutesLabel.hidden = true
                self.fullTimeLabel.hidden = false
            }
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
        self.minutesLabel.text = nil
        self.fullTimeLabel.text = nil
    }
}
