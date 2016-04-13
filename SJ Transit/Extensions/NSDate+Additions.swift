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
            return DateFormatter.PSTDateFormatterDay.stringFromDate(self)
        }
    }
    
    
    var timeAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterTime.stringFromDate(self)
        }
    }
    
    
    var timeWithMeridianAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterTimeWithMeridian.stringFromDate(self)
        }
    }
    
    
    var dateAsString: String! {
        get {
            return DateFormatter.PSTDateFormatterDate.stringFromDate(self)
        }
    }
    
    
    func minutesFromNow() -> Int {
        // first form a date with today's date and the given time
        let calendar = NSCalendar.currentCalendar()
        // TODO:- fix this timezone
        calendar.timeZone = NSTimeZone(name: "America/Los_Angeles")!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let (hour, minutes, seconds, _) = calendar.getTimeFromDate(self)
        let newDate = calendar.dateBySettingHour(hour, minute: minutes, second: seconds, ofDate: NSDate(), options: [])
        
        let difference = Int((newDate?.timeIntervalSinceDate(NSDate()))!)
        
        return (difference / 60)
    }
}