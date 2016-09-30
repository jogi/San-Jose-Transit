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
    case avaialble = 0
    case unavailable = 1
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
    var startDate: Date!
    var endDate: Date!
    var monday: ServiceAvailble!
    var tuesday: ServiceAvailble!
    var wednesday: ServiceAvailble!
    var thursday: ServiceAvailble!
    var friday: ServiceAvailble!
    var saturday: ServiceAvailble!
    var sunday: ServiceAvailble!
    
    class func isServiceActive(_ date: Date, serviceId: String) -> Bool {
        guard let db = Database.connection else {
            return false
        }
        
        let calendar = Table("calendar")
        let colServiceId = Expression<String>("service_id")
        let colStartDate = Expression<String>("start_date")
        let colEndDate = Expression<String>("end_date")
        let colToday = Expression<Int>(date.dayAsString)
        
        var count = 0
        
        do {
            count = try db.scalar(calendar.filter(colServiceId == serviceId && colStartDate <= date.dateAsString && colEndDate >= date.dateAsString && colToday == 1).count)
        } catch {
            print("Failed to execute isServiceActive query: \(error)")
        }
        
        return count > 0
    }
}
