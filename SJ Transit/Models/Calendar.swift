//
//  Calendar.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/5/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SQLite

enum ServiceAvailble: Int {
    case Avaialble = 0
    case Unavailable = 1
}


enum CalendarWeekday: Int {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}


class Calendar: NSObject {
    var serviceId: String!
    var startDate: NSDate!
    var endDate: NSDate!
    var monday: ServiceAvailble!
    var tuesday: ServiceAvailble!
    var wednesday: ServiceAvailble!
    var thursday: ServiceAvailble!
    var friday: ServiceAvailble!
    var saturday: ServiceAvailble!
    var sunday: ServiceAvailble!
    
    class func isServiceActive(date: NSDate, serviceId: String) -> Bool {
        guard let db = Database.connection else {
            return false
        }
        
        let calendar = Table("calendar")
        let colServiceId = Expression<String>("service_id")
        let colStartDate = Expression<String>("start_date")
        let colEndDate = Expression<String>("end_date")
        let colToday = Expression<Int>(date.dayAsString)
        
        let count = db.scalar(calendar.filter(colServiceId == serviceId && colStartDate <= date.dateAsString && colEndDate >= date.dateAsString && colToday == 1).count)
        
        return count > 0
    }
}
