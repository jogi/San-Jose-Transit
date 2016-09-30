//
//  NSDate+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import Foundation


extension Date {
    var dayAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterDay.string(from: self)
        }
    }
    
    
    var timeAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterTime.string(from: self)
        }
    }
    
    
    var timeWithMeridianAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterTimeWithMeridian.string(from: self)
        }
    }
    
    
    var dateAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterDate.string(from: self)
        }
    }
    
    
    func minutesFromNow() -> Int {
        // first form a date with today's date and the given time
        var calendar = Foundation.Calendar.current
        // TODO:- fix this timezone
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        let newDate = (calendar as NSCalendar).date(bySettingHour: dateComponents.hour!, minute: dateComponents.minute!, second: dateComponents.second!, of: Date(), options: [])
        let difference = Int((newDate?.timeIntervalSince(Date()))!)
        
        return (difference / 60)
    }
}
