//
//  TripStopTableViewCell.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/8/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit

class TripStopTableViewCell: UITableViewCell, IdentifiableNibBasedCell {
    // MARK: - IBOutlets
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var stopTime: StopTime? {
        didSet {
            self.stopNameLabel.text = stopTime?.stop.stopName
            self.timeLabel.text = stopTime?.arrivalTime.timeWithMeridianAsString
        }
    }
    
    class func cellIdentifier() -> String {
        return "TripStopTableViewCell"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.circleView.layer.cornerRadius = self.circleView.frame.size.height / 2.0
        self.circleView.layer.borderColor = UIColor.whiteColor().CGColor
        self.circleView.layer.borderWidth = 1.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.topLineView.hidden = false
        self.bottomLineView.hidden = false
        self.stopNameLabel.text = nil
        self.timeLabel.text = nil
    }
}
