//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-09.
//

import Foundation

extension Date {
    /// Convenience to return date components.
    ///
    /// - parameter timezone: `TimeZone` used to generate the date components. By default the current timezone is used.
    /// - parameter calendar: `Calendar` used to generate the data components. By default the gregorian calendar is used. Currently SwiftIcal can only supports Gregorian calendars.
    public func components(in timezone: TimeZone = .current,
                           calendar: Calendar = Calendar(identifier: .gregorian)) -> DateComponents {
        var components = calendar.dateComponents(in: timezone, from: self)
        components.calendar = calendar
        return components
    }
}
