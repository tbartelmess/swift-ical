//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-03.
//

import XCTest
import Foundation
@testable import SwiftIcal


class TimezoneTests: XCTestCase {

    func testSouthGeoriga() {
        XCTAssertNotNil(TimeZone(identifier: "Atlantic/South_Georgia")?.icalString)
    }
    func testOne() {

        TimeZone.knownTimeZoneIdentifiers.forEach { (timezoneIdentifier) in
            if timezoneIdentifier == "GMT" { return }
            guard let timezone = TimeZone(identifier: timezoneIdentifier) else {
                XCTFail("TimeZone did not return a timezone for \(timezoneIdentifier)")
                return
            }
        }

    }

    static var allTests = [
        ("testSouthGeoriga", testSouthGeoriga),
        ("testOne", testOne),
    ]
}
