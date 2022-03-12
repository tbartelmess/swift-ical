//
//  AttendeeTests.swift
//  
//
//  Created by Blažej Brezoňák on 12/03/2022.
//

import XCTest
@testable import SwiftIcal


class AttendeeTests: XCTestCase {
    func testAttendeeMail() {
        let attendee = Attendee(address: "thomas@bartelmess.io")
        let expected = """
        ATTENDEE:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeMailName() {
        let attendee = Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeMailNameXParameter() {
        var attendee = Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")
        attendee.xParameters = ["X-NAME": "1"]
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess;X-NAME=1:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeMailNameXParameters() {
        var attendee = Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")
        let xParameters = ["X-NAME": "1", "X-NAME2": "0"]
        attendee.xParameters = xParameters
        let attendeePropertyString = attendee.libicalProperty().icalPropertyString
        
        for xParameter in xParameters {
            if !attendeePropertyString.contains("\(xParameter.key)=\(xParameter.value)") {
                XCTFail()
            }
        }
    }
    
    func testAttendeeTypeIndividual() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .individual, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeTypeRoom() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .room, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CUTYPE=ROOM;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeTypeGroup() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .group, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CUTYPE=GROUP;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeTypeResource() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .resource, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CUTYPE=RESOURCE;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeTypeUnknown() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .unknown, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CUTYPE=UNKNOWN;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeTypeX() {
        let attendee = Attendee(address: "thomas@bartelmess.io", type: .x("TEST"), commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CUTYPE=TEST;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusNeedsAction() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .needsAction, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusAccepted() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .accepted, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;PARTSTAT=ACCEPTED;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusDeclined() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .decliend, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;PARTSTAT=DECLINED;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusTentative() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .tentative, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;PARTSTAT=TENTATIVE;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusDelegated() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .delegated, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;PARTSTAT=DELEGATED;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeParticipationStatusX() {
        let attendee = Attendee(address: "thomas@bartelmess.io", participationStatus: .x("TEST"), commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;PARTSTAT=TEST;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRoleRequiredParticipant() {
        let attendee = Attendee(address: "thomas@bartelmess.io", role: .requiredParticipant, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRoleChair() {
        let attendee = Attendee(address: "thomas@bartelmess.io", role: .chair, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;ROLE=CHAIR;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRoleOptionalParticipant() {
        let attendee = Attendee(address: "thomas@bartelmess.io", role: .optionalParticipant, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;ROLE=OPT-PARTICIPANT;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRoleNonParticipant() {
        let attendee = Attendee(address: "thomas@bartelmess.io", role: .nonParticipant, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;ROLE=NON-PARTICIPANT;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRoleX() {
        let attendee = Attendee(address: "thomas@bartelmess.io", role: .x("TEST"), commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;ROLE=TEST;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRSVPTrue() {
        let attendee = Attendee(address: "thomas@bartelmess.io", rsvp: true, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess;RSVP=TRUE:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeRSVPFalse() {
        let attendee = Attendee(address: "thomas@bartelmess.io", rsvp: false, commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeMember() {
        let attendee = Attendee(address: "thomas@bartelmess.io", member: "member@member.io", commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;MEMBER=member@member.io;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeDelegatedTo() {
        let attendee = Attendee(address: "thomas@bartelmess.io", delegatedTo: ["delegat@delwegate.io"], commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;DELEGATED-TO=delegat@delwegate.io;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeDelegatedTo2() {
        let attendee = Attendee(address: "thomas@bartelmess.io", delegatedTo: ["delegat@delwegate.io", "delegat2@delwegate.io"], commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;DELEGATED-TO="delegat@delwegate.io,delegat2@delwegate.io";
         CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeDelegatedFrom() {
        let attendee = Attendee(address: "thomas@bartelmess.io", delegatedFrom: ["delegat@delwegate.io"], commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;DELEGATED-FROM=delegat@delwegate.io;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeDelegatedFrom2() {
        let attendee = Attendee(address: "thomas@bartelmess.io", delegatedFrom: ["delegat@delwegate.io", "delegat2@delwegate.io"], commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;DELEGATED-FROM="delegat@delwegate.io,delegat2@delwegate.io";
         CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
    
    func testAttendeeSendBy() {
        let attendee = Attendee(address: "thomas@bartelmess.io", sentBy: "sent@by.io", commonName: "Thomas Bartelmess")
        let expected = """
        ATTENDEE;SENT-BY=sent@by.io;CN=Thomas Bartelmess:mailto:
         thomas@bartelmess.io
        """
        XCTAssertEqual(attendee.libicalProperty().icalPropertyString, expected.icalFormatted)
    }
}
