//
//  DateHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
/**
 The DateHelper class provides some common and useful Date related functionality.
 */
open class DateHelper {
    
    // MARK: - Singleton
    public static let shared = DateHelper()
    
    // MARK: - State Variables
    /**
     This member maps DateFormatter strings to DateFormatter instances so that the latter can be reused.
     */
    private var cache = [String: DateFormatter]()
    
    // MARK: - Helper Methods -
    /**
     This method creates a Date instance since the 1970
     
     - parameters:
        - timeInterval: time since 1970
     
     - returns: a date
     */
    open func getDate(timeInterval: TimeInterval) -> Date? {
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    /**
     This method converts a string to a date, reusing Date formatters whenever possible.
     
     - parameters:
     - format: The desired date format
     - str: The stringified date instance
     
     - returns: returns a Date instance if it can be decoded
     */
    open func getDate(format: String, str: String) -> Date? {
        let dateFormatter = cache.get(format) { () -> DateFormatter? in
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = EthosUtilConfig.shared.locale
            formatter.dateFormat = format
            return formatter
        }
        
        return dateFormatter?.date(from: str)
    }
    
    /**
     This method converts a date to a string, reusing Date formatters whenever possible.
     
     - parameters:
     - format: The desired date format
     - date: The date to be stringified
     
     - returns: returns a Date instance if it can be decoded
     */
    open func getString(format: String, date: Date) -> String? {
        let dateFormatter = cache.get(format) { () -> DateFormatter? in
            let formatter = DateFormatter()
            formatter.locale = EthosUtilConfig.shared.locale
            formatter.dateFormat = format
            return formatter
        }
        return dateFormatter?.string(from: date)
    }
    
}
