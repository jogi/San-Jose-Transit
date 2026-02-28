import UIKit

class StopRouteTimeTableViewCell: UITableViewCell, IdentifiableCell {
    // MARK: - IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tripHeadsignLabel: UILabel!
    
    // Properties
    var stopTime: StopRouteSummary! {
        didSet {
            self.timeLabel.text = stopTime.arrivalTime.timeWithMeridianAsString
            if let directionIdentifier = stopTime.directionIdentifier {
                self.tripHeadsignLabel.text = directionIdentifier.transitDirectionDescription + " to " + (stopTime.tripHeadsign ?? "")
            } else {
                self.tripHeadsignLabel.text = stopTime.tripHeadsign
            }
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
