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
        var calendar = VCalendar()
        calendar.events.append(event)
        let string = calendar.icalString()
        print(string)
    }

    func testEventWithAttendees() {
        var event = VEvent(summary: "Hello World", dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.attendees = [Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")]
        var calendar = VCalendar()
        calendar.events.append(event)
        let string = calendar.icalString()
        print(string)
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

        let event = VEvent(summary: "Hello World", dtstart: start, dtend: end)
       var calendar = VCalendar()
        calendar.events.append(event)
        print(calendar.icalString())
    }
}
