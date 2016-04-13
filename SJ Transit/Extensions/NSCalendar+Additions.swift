// NSCalendar+Additions.swift
// A set of Swift-idiomatic methods for NSCalendar
//
// (c) 2015 Nate Cook, licensed under the MIT license

import Foundation

extension NSCalendar {
    /// Returns the hour, minute, second, and nanoseconds of a given date.
    func getTimeFromDate(date: NSDate) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        var (hour, minute, second, nanosecond) = (0, 0, 0, 0)
        getHour(&hour, minute: &minute, second: &second, nanosecond: &nanosecond, fromDate: date)
        return (hour, minute, second, nanosecond)
    }
    
    /// Returns the era, year, month, and day of a given date.
    func getDateItemsFromDate(date: NSDate) -> (era: Int, year: Int, month: Int, day: Int) {
        var (era, year, month, day) = (0, 0, 0, 0)
        getEra(&era, year: &year, month: &month, day: &day, fromDate: date)
        return (era, year, month, day)
    }
    
    /// Returns the era, year for week-of-year calculations, week of year, and weekday of a given date.
    func getWeekItemsFromDate(date: NSDate) -> (era: Int, yearForWeekOfYear: Int, weekOfYear: Int, weekday: Int) {
        var (era, yearForWeekOfYear, weekOfYear, weekday) = (0, 0, 0, 0)
        getEra(&era, yearForWeekOfYear: &yearForWeekOfYear, weekOfYear: &weekOfYear, weekday: &weekday, fromDate: date)
        return (era, yearForWeekOfYear, weekOfYear, weekday)
    }
    
    /// Returns the start and length of the next weekend after the given date. Returns nil if the
    /// calendar or locale don't support weekends.
    func nextWeekendAfterDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
        var startDate: NSDate?
        var interval: NSTimeInterval = 0
        
        if nextWeekendStartDate(&startDate, interval: &interval, options: [], afterDate: date),
            let startDate = startDate
        {
            return (startDate, interval)
        }
        
        return nil
    }
    
    /// Returns the start and length of the weekend before the given date. Returns nil if the
    /// calendar or locale don't support weekends.
    func nextWeekendBeforeDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
        var startDate: NSDate?
        var interval: NSTimeInterval = 0
        
        if nextWeekendStartDate(&startDate, interval: &interval, options: .SearchBackwards, afterDate: date),
            let startDate = startDate
        {
            return (startDate, interval)
        }
        
        return nil
    }
    
    /// Returns the start and length of the weekend containing the given date. Returns nil if the
    /// given date isn't in a weekend or if the calendar or locale don't support weekends.
    func rangeOfWeekendContainingDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
        var startDate: NSDate?
        var interval: NSTimeInterval = 0
        
        if rangeOfWeekendStartDate(&startDate, interval: &interval, containingDate: date),
            let startDate = startDate
        {
            return (startDate, interval)
        }
        
        return nil
    }
}
