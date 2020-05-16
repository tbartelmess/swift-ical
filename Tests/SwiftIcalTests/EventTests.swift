//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-08.
//

import Foundation
import SwiftIcal
import XCTest


let testTimezone =  TimeZone(identifier: "America/Santiago")!
extension Date {

    var components: DateComponents {
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.dateComponents(in: testTimezone, from: self)
    }


}

extension DateComponents {
    static func testDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> DateComponents {
        DateComponents(calendar: .init(identifier: .gregorian),
                       timeZone: testTimezone,
                       year: year,
                       month: month,
                       day: day,
                       hour: hour,
                       minute: minute,
                       second: second)
    }
}

class EventTests: XCTestCase {
    func testSimpleEvent() {
        var event = VEvent(summary: "Hello World", dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        event.uid = "TEST-UID"
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=America/Santiago:20200509T110000
        DTEND;TZID=America/Santiago:20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        END:VEVENT
        END:VCALENDAR
        """
        XCTAssertEqual(calendar.icalString(), expected.icalFormatted)
    }

    func testEventWithAttendees() {
        var event = VEvent(summary: "Hello World", dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.attendees = [Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")]
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        event.uid = "TEST-UID"
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false

        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=America/Santiago:20200509T110000
        DTEND;TZID=America/Santiago:20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        END:VEVENT
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }

    func testDemo() {
        let timezone = TimeZone(identifier: "America/Toronto")

        let start = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                                   timeZone: timezone,
                                   year: 2020,
                                   month: 5,
                                   day: 9,
                                   hour: 22,
                                   minute: 0,
                                   second: 0)

        let end = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                                 timeZone: timezone,
                                 year: 2020,
                                 month: 5,
                                 day: 9,
                                 hour: 23,
                                 minute: 0,
                                 second: 0
                )

        var event = VEvent(summary: "Hello World", dtstart: start, dtend: end)
        event.uid = "TEST-UID"
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=America/Toronto:20200509T220000
        DTEND;TZID=America/Toronto:20200509T230000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        END:VEVENT
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }
}
