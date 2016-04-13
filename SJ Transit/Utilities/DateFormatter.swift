//
//  NSDateFormatter+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/12/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation

class DateFormatter {
    static let PSTDateFormatterDay: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Los_Angeles")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    static let PSTDateFormatterTime: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Los_Angeles")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter
    }()
    
    static let PSTDateFormatterTimeWithMeridian: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Los_Angeles")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter
    }()
    
    static let PSTDateFormatterDate: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Los_Angeles")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let SQLTimeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "America/Los_Angeles")
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}