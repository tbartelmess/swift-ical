//
//  AlarmTests.swift
//  
//
//  Created by Blažej Brezoňák on 05/03/2022.
//

import XCTest
import CLibical
import Foundation
@testable import SwiftIcal

class AlarmTests: XCTestCase {
    func testAlertDisplayDuration() {
        let alarm = VAlarm(trigger: .duration(duration: Duration(seconds: 0, minutes: 30, hours: 0, days: 0, weeks: 0)), action: .display(description: "Remind me"))
        let alarmComponent = alarm.libicalComponent().icalComponentString
        let expected = """
        BEGIN:VALARM
        TRIGGER:-PT30M
        ACTION:DISPLAY
        DESCRIPTION:Remind me
        END:VALARM
        """
        AssertICSEqual(alarmComponent, expected.icalFormatted)
    }
    
    func testAlertDisplayDate() {
        let alarm = VAlarm(trigger: .time(date: .testDate(year: 2023, month: 5, day: 9, hour: 11, minute: 0, second: 0)), action: .display(description: "Remind me"))
        let alarmComponent = alarm.libicalComponent().icalComponentString
        let expected = """
        BEGIN:VALARM
        TRIGGER;VALUE=DATE-TIME:20230509T110000
        ACTION:DISPLAY
        DESCRIPTION:Remind me
        END:VALARM
        """
        AssertICSEqual(alarmComponent, expected.icalFormatted)
    }
    
    func testAlertEmailDuration() {
        let alarm = VAlarm(trigger: .duration(duration: Duration(seconds: 30, minutes: 30, hours: 2, days: 1, weeks: 1)), action: .email(summary: "summary", description: "description", attendees: [Attendee(address: "test@test.com"), Attendee(address: "test2@test.com")]))
        let alarmComponent = alarm.libicalComponent().icalComponentString
        let expected = """
        BEGIN:VALARM
        TRIGGER:-P1W1DT2H30M30S
        ACTION:EMAIL
        SUMMARY:summary
        DESCRIPTION:description
        ATTENDEE:mailto:test@test.com
        ATTENDEE:mailto:test2@test.com
        END:VALARM
        """
        AssertICSEqual(alarmComponent, expected.icalFormatted)
    }
    
    func testAlertEmailDate() {
        let alarm = VAlarm(trigger: .time(date: .testDate(year: 2023, month: 5, day: 9, hour: 11, minute: 0, second: 0)), action: .email(summary: "summary", description: "description", attendees: [Attendee(address: "test@test.com"), Attendee(address: "test2@test.com")]))
        let alarmComponent = alarm.libicalComponent().icalComponentString
        let expected = """
        BEGIN:VALARM
        TRIGGER;VALUE=DATE-TIME:20230509T110000
        ACTION:EMAIL
        SUMMARY:summary
        DESCRIPTION:description
        ATTENDEE:mailto:test@test.com
        ATTENDEE:mailto:test2@test.com
        END:VALARM
        """
        AssertICSEqual(alarmComponent, expected.icalFormatted)
    }
    
    func testAlertDisplayDurationRepeat() {
        var alarm = VAlarm(trigger: .duration(duration: Duration(seconds: 0, minutes: 30, hours: 0, days: 0, weeks: 0)), action: .display(description: "Remind me"))
        alarm.frequent = AlarmFrequent(frequent: 25, duration: Duration(seconds: 0, minutes: 30, hours: 0, days: 0, weeks: 0))
        let alarmComponent = alarm.libicalComponent().icalComponentString
        let expected = """
        BEGIN:VALARM
        TRIGGER:-PT30M
        ACTION:DISPLAY
        DESCRIPTION:Remind me
        DURATION:PT30M
        REPEAT:25
        END:VALARM
        """
        AssertICSEqual(alarmComponent, expected.icalFormatted)
    }
    
    func testAlertInEvent() {
        var event = VEvent(summary: "Hello World",
                           dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        event.uid = "TEST-UID"
        
        var alarm = VAlarm(trigger: .duration(duration: Duration(seconds: 0, minutes: 30, hours: 0, days: 0, weeks: 0)), action: .display(description: "Remind me"))
        alarm.frequent = AlarmFrequent(frequent: 25, duration: Duration(seconds: 0, minutes: 30, hours: 0, days: 0, weeks: 0))
        event.alarm = alarm
        
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false
        
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T110000
        DTEND;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        BEGIN:VALARM
        TRIGGER:-PT30M
        ACTION:DISPLAY
        DESCRIPTION:Remind me
        DURATION:PT30M
        REPEAT:25
        END:VALARM
        END:VEVENT
        END:VCALENDAR
        """
        AssertICSEqual(calendar.icalString(), expected.icalFormatted)
    }
}
