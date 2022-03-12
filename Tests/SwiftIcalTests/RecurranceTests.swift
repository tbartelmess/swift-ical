//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-10.
//

import XCTest
import Foundation
import CLibical
@testable import SwiftIcal

extension LibicalProperty {
    var icalString: String {
        let stringPointer = icalproperty_as_ical_string(self)!
        var string = String(cString: stringPointer)
        defer { stringPointer.deallocate() }


        string.removeLast()
        return string
    }
}

extension RecurranceRule {
    var icalString: String {
        libicalProperty().icalString
    }
}


class RecurranceTests: XCTestCase {
    func testSimpleSecondlyRule() {
        let rule = RecurranceRule(frequency: .secondly)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=SECONDLY")
    }

    func testSimpleMinutelyRule() {
        let rule = RecurranceRule(frequency: .minutely)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=MINUTELY")
    }

    func testSimpleHourlyRule() {
        let rule = RecurranceRule(frequency: .hourly)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=HOURLY")
    }

    func testSimpleDailyRule() {
        let rule = RecurranceRule(frequency: .daily)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=DAILY")
    }

    func testSimpleWeeklyRule() {
        let rule = RecurranceRule(frequency: .weekly)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=WEEKLY")
    }

    func testSimpleMonthlyRule() {
        let rule = RecurranceRule(frequency: .monthly)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=MONTHLY")
    }

    func testSimpleYearlyRule() {
        let rule = RecurranceRule(frequency: .yearly)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=YEARLY")
    }

    func testCount() {
        // Repeats daily for two times
        let rule = RecurranceRule(frequency: .daily, count: 2)
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=DAILY;COUNT=2")
    }

    func testEndUTCDateTime() {
        let rule = RecurranceRule(frequency: .daily, until: DateComponents(calendar: .current, timeZone: TimeZone.init(identifier: "UTC"), year: 2020, month: 5, day: 10))
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=DAILY;UNTIL=20200510T000000Z")
    }

    func testByHour() {
        var rule = RecurranceRule(frequency: .daily)
        rule.byHour = Set([0, 2, 4, 6])
        XCTAssertEqual(rule.icalString, "RRULE:FREQ=DAILY;BYHOUR=0,2,4,6")
    }



    static var allTests = [
        ("testSimpleSecondlyRule", testSimpleSecondlyRule),
        ("testSimpleMinutelyRule", testSimpleMinutelyRule),
        ("testSimpleHourlyRule", testSimpleHourlyRule),
        ("testSimpleDailyRule", testSimpleDailyRule),
        ("testSimpleWeeklyRule", testSimpleWeeklyRule),
        ("testSimpleMonthlyRule", testSimpleMonthlyRule),
        ("testSimpleYearlyRule", testSimpleYearlyRule),
        ("testCount", testCount),
        ("testEndUTCDateTime", testEndUTCDateTime),
        ("testByHour", testByHour)


    ]
}
