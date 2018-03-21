//
//  NSDateFormatter+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/12/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation

class DateFormatter {
    static let PSTDateFormatterDay: Foundation.DateFormatter = {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    static let PSTDateFormatterTime: Foundation.DateFormatter = {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter
    }()
    
    static let PSTDateFormatterTimeWithMeridian: Foundation.DateFormatter = {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter
    }()
    
    static let PSTDateFormatterDate: Foundation.DateFormatter = {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let SQLTimeFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
