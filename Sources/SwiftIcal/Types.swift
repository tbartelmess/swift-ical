//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-03.
//

import Foundation
import CLibical


typealias LibicalTimezone = UnsafeMutablePointer<_icaltimezone>
extension TimeZone {

    func loadZones() {
        #if os(Linux)
        print("Setting zone directory to /usr/share/zoneinfo/")
        set_zone_directory("/usr/share/zoneinfo/")
        #endif
        #if os(macOS)
        // In macOS 10.13+ the location of the zoneinfo changed.
        // See https://github.com/apple/swift-corelibs-foundation/blob/7c8f145c834b3a97499fec12d67499eef825a3a4/CoreFoundation/NumberDate.subproj/CFTimeZone.c#L49
        if ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
            set_zone_directory("/var/db/timezone/zoneinfo/")
        } else {
            set_zone_directory("/usr/share/zoneinfo/")
        }
        #endif

        icaltimezone_set_tzid_prefix("SwiftLibical/")
    }

    var icalTimeZone: LibicalTimezone {
        loadZones()
        if self.identifier == "UTC" || self.identifier == "GMT" {
            return icaltimezone_get_utc_timezone()
        }
        return icaltimezone_get_builtin_timezone_from_tzid("SwiftLibical/\(self.identifier)")
    }

    var icalComponent: LibicalComponent {
        loadZones()

        let tz = icaltimezone_get_builtin_timezone_from_tzid("SwiftLibical/\(self.identifier)")
        let comp = icaltimezone_get_component(tz)
        
        return comp!
    }

    public var icalString: String {
        guard let stringPointer = icalcomponent_as_ical_string(icalComponent) else {
            fatalError("Failed to get component as string")
        }
        let string = String(cString: stringPointer)
        icalmemory_free_buffer(stringPointer)
        return string
    }

}





extension Date {
    func icalTime(in calendar: Calendar = .autoupdatingCurrent, utc: Bool = false) -> icaltimetype {
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)

        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)

        var timezone: UnsafeMutablePointer<icaltimezone>? = nil
        if utc {
            timezone = icaltimezone_get_utc_timezone()
        }
        return icaltimetype(year: Int32(year), month: Int32(month), day: Int32(day), hour: Int32(hour), minute: Int32(minute), second: Int32(second), is_date: 0, is_daylight: 0, zone: timezone)
    }
}


public enum Method {
    case X(String)
    case publish
    case request
    case reply
    case add
    case cancel
    case refresh
    case counter
    case declineCounter
    case create
    case response
    case move
    case modify
    case generateUID
    case delete
    case pollStatus

    func make() -> OpaquePointer {
        switch self {

        case .X(let xString):
            return icalproperty_new_x(xString.cString(using: .utf8))
        case .publish:
            return icalproperty_new_method(ICAL_METHOD_PUBLISH)
        case .request:
            return icalproperty_new_method(ICAL_METHOD_REQUEST)
        case .reply:
            return icalproperty_new_method(ICAL_METHOD_REPLY)
        case .add:
            return icalproperty_new_method(ICAL_METHOD_ADD)
        case .cancel:
            return icalproperty_new_method(ICAL_METHOD_CANCEL)
        case .refresh:
            return icalproperty_new_method(ICAL_METHOD_REFRESH)
        case .counter:
            return icalproperty_new_method(ICAL_METHOD_COUNTER)
        case .declineCounter:
            return icalproperty_new_method(ICAL_METHOD_DECLINECOUNTER)
        case .create:
            return icalproperty_new_method(ICAL_METHOD_CREATE)
        case .response:
            return icalproperty_new_method(ICAL_METHOD_RESPONSE)
        case .move:
            return icalproperty_new_method(ICAL_METHOD_MOVE)
        case .modify:
            return icalproperty_new_method(ICAL_METHOD_MODIFY)
        case .generateUID:
            return icalproperty_new_method(ICAL_METHOD_GENERATEUID)
        case .delete:
            return icalproperty_new_method(ICAL_METHOD_DELETE)
        case .pollStatus:
            return icalproperty_new_method(ICAL_METHOD_POLLSTATUS)
        }
    }
}
