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


    func testMethod() {
        var calendar = VCalendar()
        calendar.method = .request
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        METHOD:REQUEST
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }

    func testParseEmpty() throws {
        let string = """
        BEGIN:VCALENDAR
        PRODID:-//SomeProdid/EN
        VERSION:2.0
        METHOD:REQUEST
        END:VCALENDAR
        """.icalFormatted
        let calendar = try VCalendar.parse(string)
        XCTAssertEqual(calendar.prodid, "-//SomeProdid/EN")
    }

    func testParseInvalid() throws {
        let string = "fooooo"
        XCTAssertThrowsError(try VCalendar.parse(string), "Expect a bogus string to fail") { (error) in
            guard let parseError = error as? ParseError else {
                XCTFail("Expected error to be a ParseError. Got \(error.self)")
                return
            }
            XCTAssertEqual(parseError, ParseError.invalidVCalendar)
        }

    }

    func testParseNoVersion() throws {
        let string = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        END:VCALENDAR
        """.icalFormatted
        XCTAssertThrowsError(try VCalendar.parse(string), "Expect string with missing version to fail") { (error) in
            guard let parseError = error as? ParseError else {
                XCTFail("Expected error to be a ParseError. Got \(error.self)")
                return
            }
            XCTAssertEqual(parseError, ParseError.noVersion)
        }
    }


    func testParseInvalidVersion() throws {
        let string = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:1.0
        END:VCALENDAR
        """.icalFormatted
        XCTAssertThrowsError(try VCalendar.parse(string), "Expect string with version 1.0 to fail") { (error) in
            guard let parseError = error as? ParseError else {
                XCTFail("Expected error to be a ParseError. Got \(error.self)")
                return
            }
            XCTAssertEqual(parseError, ParseError.invalidVersion)
        }
    }

    func testParseMethod() throws {
        let string = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        END:VCALENDAR
        """.icalFormatted
        let calendar = try VCalendar.parse(string)
        XCTAssertNil(calendar.method)
    }

    func testParseRequestMethod() throws {
        let string = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        METHOD: REQUEST
        END:VCALENDAR
        """.icalFormatted
        let calendar = try VCalendar.parse(string)
        XCTAssertEqual(calendar.method, .request)
    }

    static var allTests = [
        ("testParseNoVersion", testParseNoVersion),
        ("testParseInvalidVersion", testParseInvalidVersion),
        ("testParseInvalid", testParseInvalid),
        ("testEmptyCalendar", testEmptyCalendar),
        ("testProdidChange", testProdidChange),
        ("testMethod", testMethod)
    ]
}
