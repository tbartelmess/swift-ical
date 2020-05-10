import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TimezoneTests.allTests),
        testCase(VCalendarTests.allTests)
    ]
}
#endif
