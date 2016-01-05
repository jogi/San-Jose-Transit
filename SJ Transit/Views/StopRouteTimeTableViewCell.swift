//
//  StopRouteTimeTableViewCell.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class StopRouteTimeTableViewCell: UITableViewCell, IdentifiableCell {
    // MARK: - IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tripHeadsignLabel: UILabel!
    
    // Properties
    var stopTime: StopTime! {
        didSet {
            self.timeLabel.text = stopTime.arrivalTime.timeAsString
            self.tripHeadsignLabel.text = stopTime.trip.directionId.description + " to " + stopTime.trip.tripHeadsign
        }
    }
    
    class func cellIdentifier() -> String {
        return "StopRouteTimeCellIdentifier"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timeLabel.text = nil
        self.tripHeadsignLabel.text = nil
    }

}
