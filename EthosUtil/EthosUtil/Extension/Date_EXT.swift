//
//  Date_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension Date {
    
    // MARK: - String Formatting
    /**
     This property converts a date to an iso8601 formatted string.
     */
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
    
    /**
     This method converts a date to a string
     
     - parameters:
        - format: The desired string format. If the parameter is set to `nil`, the iso8601 format is used. This
                  parameter defaults to `nil`
     
     - returns: a stringified date
     */
    func toString(format: String? = nil) -> String? {
        return DateHelper.shared.getString(format: format ?? DateFormatter.iso8601.dateFormat, date: self)
    }
    
    /**
     This method returns a string representation of the largest component difference between two dates.
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
         - from: The reference date
         - compact: Set this parameter to true if the component representation should be compact. 'y' vs 'years'
     
     - returns: a string representing the largest component difference between two dates
     */
    func offset(from date: Date, compact: Bool = true) -> String {
        
        // I tried chaining these statements (stmt1 ?? stmt2 ?? ...) and the compiler freaked out. So im breaking them
        // up into this ugly set of logic blocks.
        
        var ret = formatComponent(component: compact ? "y" : "year", isCompact: compact, count: years(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "m" : "month", isCompact: compact, count: months(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "w" : "week", isCompact: compact, count: weeks(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "d" : "day", isCompact: compact, count: days(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "h" : "hour", isCompact: compact, count: hours(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "m" : "minute", isCompact: compact, count: minutes(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "s" : "second", isCompact: compact, count: seconds(from: date))
        if let r = ret { return r }
        
        ret = formatComponent(component: compact ? "ns" : "nanosecond",
                              isCompact: compact, count: nanoseconds(from: date))
        if let r = ret { return r }
        
        return ""
    }
    
    // MARK: - Relative Dates
    /**
     This method returns a new Date representing the current instance with the time components set to midnight (GMT)
     
     - returns: A new date, or nil if a date could not be calculated.
     */
    func gmtMidnight() -> Date {
        if let gmt = TimeZone(secondsFromGMT: 0) {
            var dateComponents = Calendar.current.dateComponents(in: gmt, from: self)
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            
            if let newGMTDate = Calendar.current.date(from: dateComponents) {
                return newGMTDate
            }
        }
        
        return self
    }
    
    /**
     This method returns a new Date representing exactly one day after the current instance.
     
     - note: This method keeps ALL date components include the time.
     
     - returns: A new date, or nil if a date could not be calculated.
     */
    func nextDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1), to: self)!
    }
    
    /**
     This method returns a new Date representing the first day of the month for the current instance.
     
     - note: This method ignores the current time components, setting them to 12:00 am
     
     - returns: A new date, or nil if a date could not be calculated.
     */
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month],
                                                                           from: Calendar.current.startOfDay(for: self)))!
    }
    
    /**
     This method returns a new Date representing the last day of the month for the current instance.
     
     - note: This method ignores the current time components, setting them to 12:00 am
     
     - returns: A new date, or nil if a date could not be calculated.
     */
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    /**
     This method returns a new Date representing the first day of the next month for the current instance.
     
     - note: This method ignores the current time components, setting them to 12:00 am
     
     - returns: A new date, or nil if a date could not be calculated.
     */
    func startOfNextMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1), to: self.endOfMonth())!
    }
    
    // MARK: - Date Differences
    /**
     This method returns the difference between two dates measured in years
     
     - returns: the number of years between two dates rounded down
     */
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in months
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of months between two dates rounded down
     */
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in weeks
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of weeks between two dates rounded down
     */
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in days
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of days between two dates rounded down
     */
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in hours
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of hours between two dates rounded down
     */
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in minutes
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of minutes between two dates rounded down
     */
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in seconds
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of seconds between two dates rounded down
     */
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /**
     This method returns the difference between two dates measured in nanoseconds
     
     - note: the reference date should be earlier than the instance
     
     - parameters:
        - from: The reference date
     
     - returns: the number of nanoseconds between two dates rounded down
     */
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    
    // MARK: - Helper Method
    /**
     This method adds a 's' character to the component if the count is large than 1.
     
     - parameters:
         - component: String representation of a date component
         - count: the component count
     
     - returns: a formatted component string based on the count provided
     */
    fileprivate func pluralizeComponent(_ component: String,_ count: Int) -> String {
        return (count > 1) ? "\(component)s" : "\(component)"
    }
    
    /**
     This method creates a string representing a date component count if the count is greater than 0
     
     - parameters:
         - component: String representing the date component
         - isCompact: Set to true if the component representation is compact
         - count: the component count
     
     - returns: a formatted component string or nil based on the count provided
     */
    fileprivate func formatComponent(component: String, isCompact: Bool, count: Int) -> String? {
        guard count > 0 else { return nil }
        return isCompact ? component : " \(pluralizeComponent(component, count))"
    }
    
}
