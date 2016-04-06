//
//  NSDate+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import Foundation

extension NSDate {
    var dayAsString: String! {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "PST")
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEEE"
            
            return dateFormatter.stringFromDate(self)
        }
    }
    
    
    var timeAsString: String! {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "PST")
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.dateFormat = "h:mm a"
            
            return dateFormatter.stringFromDate(self)
        }
    }
    
    
    func humanReadableTime() -> (String?) {
        // first form a date with today's date and the given time
        let calendar = NSCalendar.currentCalendar()
        // TODO:- fix this timezone
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let (hour, minutes, seconds, _) = calendar.getTimeFromDate(self)
        let newDate = calendar.dateBySettingHour(hour, minute: minutes, second: seconds, ofDate: NSDate(), options: [])
        
        let difference = Int((newDate?.timeIntervalSinceDate(NSDate()))!)
        
        return "\(difference / 60)"
    }
}