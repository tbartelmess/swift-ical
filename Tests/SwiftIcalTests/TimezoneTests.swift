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

    func testTZID() {
        let string = TimeZone(identifier: "America/Santiago")?.icalString
        XCTAssertTrue(string?.contains("TZID:/freeassociation.sourceforge.net/America/Santiago") ?? false)
    }

    static var allTests = [
        ("testSouthGeoriga", testSouthGeoriga),
        ("testTZID", testTZID),
    ]
}
