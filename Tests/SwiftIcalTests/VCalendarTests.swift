//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-10.
//

import XCTest
import SwiftIcal


class VCalendarTests: XCTestCase {
    func testEmptyCalendar() {
        let calendar = VCalendar()
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }

    func testProdidChange() {
        var calendar = VCalendar()
        calendar.prodid = "-//My Great App/EN"
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//My Great App/EN
        VERSION:2.0
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }

    static var allTests = [
        ("testEmptyCalendar", testEmptyCalendar),
        ("testProdidChange", testProdidChange),
    ]
}
