//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-03.
//

import Foundation
import CLibical


typealias LibicalTimezone = UnsafeMutablePointer<_icaltimezone>
fileprivate var zonesLoaded = false

extension TimeZone {

    func loadZones() {
        if zonesLoaded {
            return
        }
        #if os(Linux)
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

        //icaltimezone_set_tzid_prefix("")
        zonesLoaded = true
    }

    var icalTimeZone: LibicalTimezone {
        loadZones()
        if self.identifier == "UTC" || self.identifier == "GMT" {
            return icaltimezone_get_utc_timezone()
        }
        return icaltimezone_get_builtin_timezone_from_tzid(self.identifier)
    }

    public func icalComponent(useTZIDPrefix: Bool) -> LibicalComponent? {
        loadZones()
        
        let tz = icaltimezone_get_builtin_timezone_from_tzid("/freeassociation.sourceforge.net/" + self.identifier)
        let comp = icaltimezone_get_component(tz)
        
        if !useTZIDPrefix {
            let tzidProperty = icalcomponent_get_first_property(comp, ICAL_TZID_PROPERTY)
            icalproperty_set_tzid(tzidProperty, self.identifier)
        }
        
        return comp
    }
}





extension Date {
    func icalTime(in calendar: Calendar = .autoupdatingCurrent, timeZone: TimeZone) -> icaltimetype {
        let components = calendar.dateComponents(in: timeZone, from: self)
        let day = components.day ?? 0
        let month = components.month ?? 0
        let year = components.year ?? 0

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        var zone: UnsafeMutablePointer<icaltimezone>? = nil
        if timeZone == .utc {
            zone = icaltimezone_get_utc_timezone()
        }
        return icaltimetype(year: Int32(year), month: Int32(month), day: Int32(day), hour: Int32(hour), minute: Int32(minute), second: Int32(second), is_date: 0, is_daylight: 0, zone: zone)
    }
}


public enum Method: Equatable, LibicalPropertyConvertible {
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

    static func from(property: LibicalProperty) -> Self? {
        let method = icalproperty_get_method(property)
        switch method {
        case ICAL_METHOD_PUBLISH:
            return .publish
        case ICAL_METHOD_REQUEST:
            return .request
        case ICAL_METHOD_REPLY:
            return .reply
        case ICAL_METHOD_ADD:
            return .add
        case ICAL_METHOD_CANCEL:
            return .cancel
        case ICAL_METHOD_REFRESH:
            return .refresh
        case ICAL_METHOD_COUNTER:
            return .counter
        case ICAL_METHOD_DECLINECOUNTER:
            return .declineCounter
        case ICAL_METHOD_CREATE:
            return .create
        case ICAL_METHOD_RESPONSE:
            return .response
        case ICAL_METHOD_MOVE:
            return .move
        case ICAL_METHOD_MODIFY:
            return .modify
        case ICAL_METHOD_GENERATEUID:
            return .generateUID
        case ICAL_METHOD_DELETE:
            return .delete
        case ICAL_METHOD_POLLSTATUS:
            return .pollStatus
        case ICAL_METHOD_X:
            if let string = icalproperty_get_x(property) {
                return .X(String(cString: string))
            }
            return nil
        default:
            return nil
        }
    }

    func libicalProperty() -> LibicalProperty {
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
