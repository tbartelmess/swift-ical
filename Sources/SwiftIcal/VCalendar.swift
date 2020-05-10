//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-10.
//

import Foundation
import CLibical

/// A VCalendar is the core object. When exchanging data with other clients, they are always embedded inside of a VCalendar.
/// A VCalendar can be seen as a container for other Calendaring and Scheduling objects. It contains `timezones` and `events`.
///
/// ## Basic usage
///
/// By default a creating a new `VCalendar` does not require any arguments.
/// ```swift
/// var calendar = VCalendar()
/// calendar.icalString()
/// ```
///
///
///
/// ```
/// BEGIN:VCALENDAR
/// PRODID:-//SwiftIcal/EN
/// VERSION:2.0
/// END:VCALENDAR
/// ```
///
/// ## Adding Events
///
/// Events can be added by appending to the `events` property.
///
/// By default adding a VEvent will also timezone definitions for all timezones used in the `icalString()`
/// If this behaviour is not wanted, it can be disabled by setting `autoincludeTimezones` to `false`
///
public struct VCalendar {

    /// Product identifier.
    ///
    /// Application should set this property to a value to represent the product.
    /// Most calendaring applications do not display this information to users.
    /// For details refer to [Section 3.7.3 of RFC 5545](https://tools.ietf.org/html/rfc5545#section-3.7.3)
    public var prodid = "-//SwiftIcal/EN"

    /// Object Method for the VCalendar. Only if the Calendar is used for scheduling, a method needs is required.
    /// For details, refer to [RFC5546](https://tools.ietf.org/html/rfc5546) to learn more about
    /// the iCalendar Transport-Independent Interoperability Protocol (iTIP) and the methods it uses.
    public var method: Method?

    /// VCalendar version, currently only 2.0 is supported.
    public var version: CalendarVersion = .version2_0

    /// Timezones in the VCalendar.
    public var timezones: [TimeZone] = []

    /// VEvents in the Calendar.
    public var events: [VEvent] = []


    /// If `autoincludeTimezones` is enabled, timezone definitions for all
    /// timezones used in `vevents` will be added to the `VCALENDAR` output.
    public var autoincludeTimezones = true

    /// Creates a new `VCALENDAR`
    public init() {}

    /// Returns the `VCALENDAR` representation as a string
    public func icalString() -> String {
        let c = component()

        //defer { icalmemory_free_buffer(c) }
        guard let stringPointer = icalcomponent_as_ical_string(c) else {
            fatalError("Failed to get component as string")
        }
        defer {icalmemory_free_buffer(stringPointer)}

        let string = String(cString: stringPointer)
        return string
    }

    /// Serializes the the component into a libical structure.
    /// It's the callers responsibliy to call `icalcomponent_free` to free
    /// the libical data structure.
    func component() -> LibicalComponent {
        let calendar = icalcomponent_new_vcalendar()!
        icalcomponent_add_property(calendar, icalproperty_new_prodid(prodid))
        icalcomponent_add_property(calendar, icalproperty_new_version(version.rawValue))
        if let method = method {
            icalcomponent_add_property(calendar, method.libicalProperty())
        }
        var allTimezones = Set<TimeZone>(self.timezones)

        if autoincludeTimezones {
            events.forEach { (event) in
                if let timezone = event.dtstart.timeZone {
                    allTimezones.insert(timezone)
                }
                if let timezone = event.dtend?.timeZone {
                    allTimezones.insert(timezone)
                }
            }
        }



        allTimezones.forEach { (timezone) in
            icalcomponent_add_component(calendar, timezone.icalComponent)
        }
        events.forEach { event in
            icalcomponent_add_component(calendar, event.libicalComponent())
        }

        return calendar
    }
}

/// Choices for the Calendar version.
/// See [RFC 3.7.4](https://tools.ietf.org/html/rfc5545#section-3.7.4)
public enum CalendarVersion: String {
    /// Version 2.0
    case version2_0 = "2.0"
}
