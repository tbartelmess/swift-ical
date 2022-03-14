import CLibical
import Foundation

typealias LibicalComponent = OpaquePointer
typealias LibicalProperty = OpaquePointer
typealias LibicalParameter = OpaquePointer

protocol LibicalComponentConvertible {
    func libicalComponent() -> LibicalComponent
}

protocol LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty
}

protocol LibicalParameterConvertible {
    func libicalParameter() -> LibicalParameter
}

extension LibicalComponent {
    subscript(kind: icalproperty_kind) -> [LibicalProperty] {
        var result: [LibicalProperty] = []
        if let first = icalcomponent_get_first_property(self, kind) {
            result.append(first)
        }
        while let property = icalcomponent_get_next_property(self, kind) {
            result.append(property)
        }
        return result
    }

    subscript(kind: icalcomponent_kind)-> [LibicalComponent] {
        var result: [LibicalComponent] = []
        if let first = icalcomponent_get_first_component(self, kind) {
            result.append(first)
        }
        while let property = icalcomponent_get_next_component(self, kind) {
            result.append(property)
        }
        return result
    }
    
    subscript(kind: icalparameter_kind)-> [LibicalParameter] {
        var result: [LibicalParameter] = []
        if let first = icalproperty_get_first_parameter(self, kind) {
            result.append(first)
        }
        while let property = icalproperty_get_next_parameter(self, kind) {
            result.append(property)
        }
        return result
    }
}

extension LibicalProperty {
    var value: String? {
        guard let ptr = icalproperty_get_value_as_string(self) else {
            return nil
        }
        return String(cString: ptr)
    }
}

extension LibicalComponent {
    public var icalComponentString: String {
        let c = self
        
        guard let stringPointer = icalcomponent_as_ical_string(c) else {
            fatalError("Failed to get component as string")
        }
        defer {
            icalmemory_free_buffer(stringPointer)
        }
        
        let string = String(cString: stringPointer)
        return string
    }
}

extension LibicalComponent {
    public var icalPropertyString: String {
        let c = self
        
        guard let stringPointer = icalproperty_as_ical_string(c) else {
            fatalError("Failed to get property as string")
        }
        defer {
            icalmemory_free_buffer(UnsafeMutableRawPointer(mutating: stringPointer))
        }

        let string = String(cString: stringPointer)
        return string
    }
}

extension DateComponents {
    var icaltime: icaltimetype {
        icaltimetype(year: Int32(year ?? 0),
                     month: Int32(month ?? 0),
                     day: Int32(day ?? 0),
                     hour: Int32(hour ?? 0),
                     minute: Int32(minute ?? 0),
                     second: Int32(second ?? 0),
                     is_date: 0,
                     is_daylight: 0,
                     zone: timeZone?.icalTimeZone)
    }
}

/// In a VEvent the time of the event can be specificed using a start and end time
/// or a start time and a duration.
public enum EventTime {
    case startEnd(DateComponents, DateComponents)
    case startDuration(DateComponents, TimeInterval)
}


public enum Calscale {
    case gregorian
}

public typealias CalendarUserAddress = String

extension CalendarUserAddress {
    var mailtoAddress: String {
        return "mailto:\(self)"
    }
}


public typealias CommonName = String

public enum CalendarUserType: Equatable {

    /// Experimental type
    case x(String)

    /// An individual
    case individual

    /// A group of individuals
    case group

    /// A physical resource
    case resource

    /// A room resource
    case room

    /// Unknown resource type
    case unknown
}

extension CalendarUserType: LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty {
        switch self {
        case .x(let xType):
            let parameter = icalparameter_new_cutype(ICAL_CUTYPE_X)
            icalparameter_set_x(parameter, xType)
            return parameter!
        case .individual:
            return icalparameter_new_cutype(ICAL_CUTYPE_INDIVIDUAL)
        case .group:
            return icalparameter_new_cutype(ICAL_CUTYPE_GROUP)
        case .resource:
            return icalparameter_new_cutype(ICAL_CUTYPE_RESOURCE)
        case .room:
            return icalparameter_new_cutype(ICAL_CUTYPE_ROOM)
        case .unknown:
            return icalparameter_new_cutype(ICAL_CUTYPE_UNKNOWN)
        }
    }
}

public enum EventParticipationStatus: Equatable {
    /// The event needs a response from the participant.
    case needsAction

    /// The participant accepted the invitation
    case accepted

    /// The participant declined the invitation
    case decliend

    /// The participant accepted the invitation tentatively
    case tentative

    /// The participant delegated the invitation to a different user
    case delegated

    /// Custom, experimental status
    case x(String)
}

extension EventParticipationStatus: LibicalParameterConvertible {
    func libicalParameter() -> LibicalParameter {
        switch self {

        case .needsAction:
            return icalparameter_new_partstat(ICAL_PARTSTAT_NEEDSACTION)
        case .accepted:
            return icalparameter_new_partstat(ICAL_PARTSTAT_ACCEPTED)
        case .decliend:
            return icalparameter_new_partstat(ICAL_PARTSTAT_DECLINED)
        case .tentative:
            return icalparameter_new_partstat(ICAL_PARTSTAT_TENTATIVE)
        case .delegated:
            return icalparameter_new_partstat(ICAL_PARTSTAT_DELEGATED)
        case .x(let xType):
            let parameter = icalparameter_new_partstat(ICAL_PARTSTAT_X)
            icalparameter_set_x(parameter, xType)
            return parameter!
        }
    }
}

public enum Role: Equatable {
    case chair
    case requiredParticipant
    case optionalParticipant
    case nonParticipant
    case x(String)
}

extension Role: LibicalParameterConvertible {
    func libicalParameter() -> LibicalParameter {
        switch self {
        case .chair:
            return icalparameter_new_role(ICAL_ROLE_CHAIR)
        case .requiredParticipant:
            return icalparameter_new_role(ICAL_ROLE_REQPARTICIPANT)
        case .optionalParticipant:
            return icalparameter_new_role(ICAL_ROLE_OPTPARTICIPANT)
        case .nonParticipant:
            return icalparameter_new_role(ICAL_ROLE_NONPARTICIPANT)
        case .x(let xType):
            let parameter = icalparameter_new_role(ICAL_ROLE_X)
            icalparameter_set_x(parameter, xType)
            return parameter!
        }
    }
}


/// An attendee is a User, that is requested to join the event.
/// See [RFC 5545 Section 3.8.4.1](https://tools.ietf.org/html/rfc5545#section-3.8.4.1) for details
public struct Attendee {
    public init(address: CalendarUserAddress,
                type: CalendarUserType = .individual,
                participationStatus: EventParticipationStatus = .needsAction,
                role: Role = .requiredParticipant,
                rsvp: Bool = false,
                member: CalendarUserAddress? = nil,
                delegatedTo: [CalendarUserAddress]? = nil,
                delegatedFrom: [CalendarUserAddress]? = nil,
                sentBy: CalendarUserAddress? = nil,
                commonName: CommonName? = nil,
                xParameters: [String: String] = [:]) {
        self.address = address
        self.type = type
        self.participationStatus = participationStatus
        self.role = role
        self.rsvp = rsvp
        self.member = member
        self.delegatedTo = delegatedTo
        self.delegatedFrom = delegatedFrom
        self.sentBy = sentBy
        self.commonName = commonName
        self.xParameters = xParameters
    }

    /// E-Mail address of the attendee
    public var address: CalendarUserAddress

    /// The kind of the attendee, the default is `.individual`
    public var type: CalendarUserType = .individual

    /// Participation status of the attendee, the default is `.needsAction`
    public var participationStatus: EventParticipationStatus = .needsAction

    /// Role of the attendee, the default value is `.requiredParticipant`
    public var role: Role = .requiredParticipant
    
    /// Group membership.
    ///
    /// See [RFC 5545 Section 3.2.11](https://tools.ietf.org/html/rfc5545#section-3.2.11) for more details
    public var member: CalendarUserAddress?
    
    /// List for users the attendance has been delegated to.
    ///
    /// See [RFC 5545 Section 3.2.4](https://tools.ietf.org/html/rfc5545#section-3.2.5) for more details
    public var delegatedTo: [CalendarUserAddress]?
    
    /// List for users the attendance has been delegated from.
    ///
    /// See [RFC 5545 Section 3.2.4](https://tools.ietf.org/html/rfc5545#section-3.2.4) for more details
    public var delegatedFrom: [CalendarUserAddress]?
    
    /// User that has sent the invitation.
    ///
    /// See [RFC 5545 Section 3.2.18](https://tools.ietf.org/html/rfc5545#section-3.2.18) for more details
    public var sentBy: CalendarUserAddress?

    /// Common name for the attendee calendar user,
    /// e.g. John Smith.
    public var commonName: CommonName?

    /// Property if the attendee is requested to send
    public var rsvp: Bool
    
    /// Custom X parameters
    public var xParameters: [String: String] = [:]
}

extension Attendee: LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty {
        let property = icalproperty_new_attendee(self.address.mailtoAddress)
        if type != .individual {
            icalproperty_add_parameter(property, type.libicalProperty())
        }
        
        if let member = member {
            icalproperty_add_parameter(property, icalparameter_new_member(member))
        }

        if participationStatus != .needsAction {
            icalproperty_add_parameter(property, participationStatus.libicalParameter())
        }

        if role != .requiredParticipant {
            icalproperty_add_parameter(property, role.libicalParameter())
        }

        if let delegatedTo = delegatedTo {
            let string = delegatedTo.joined(separator: ",")
            icalproperty_add_parameter(property, icalparameter_new_delegatedto(string))
        }

        if let delegatedFrom = delegatedFrom {
            let string = delegatedFrom.joined(separator: ",")
            icalproperty_add_parameter(property, icalparameter_new_delegatedfrom(string))
        }

        if let sentBy = sentBy {
            icalproperty_add_parameter(property, icalparameter_new_sentby(sentBy))
        }

        if let commonName = commonName {
            icalproperty_add_parameter(property, icalparameter_new_cn(commonName))
        }

        if rsvp == true {
            icalproperty_add_parameter(property, icalparameter_new_rsvp(ICAL_RSVP_TRUE))
        }
        
        for xParameter in xParameters {
            let param = icalparameter_new_from_string("\(xParameter.key)=\(xParameter.value)")
            icalproperty_add_parameter(property, param)
        }
        
        return property!
    }
}


/// The Organizer for an Event
public struct Organizer {
    public init(address: CalendarUserAddress, commonName: CommonName? = nil, sentBy: CalendarUserAddress? = nil) {
        self.address = address
        self.commonName = commonName
        self.sentBy = sentBy
    }
    
    /// E-Mail address of the Organizer
    public var address: CalendarUserAddress

    /// Name of the Organizer
    public var commonName: CommonName?
    public var sentBy: CalendarUserAddress?
    
    /// Custom X parameters
    public var xParameters: [String: String] = [:]
}

extension Organizer: LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty {
        let property = icalproperty_new_organizer(self.address.mailtoAddress)

        if let commonName = commonName {
            icalproperty_add_parameter(property, icalparameter_new_cn(commonName))
        }
        if let sentBy = sentBy {
            icalproperty_add_parameter(property, icalparameter_new_sentby(sentBy.mailtoAddress))
        }
        
        for xParameter in xParameters {
            let param = icalparameter_new_from_string("\(xParameter.key)=\(xParameter.value)")
            icalproperty_add_parameter(property, param)
        }

        return property!
    }
}


public enum Transparency {
    case opaque
    case transparent
}

extension Transparency: LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty {
        switch self {
        case .opaque:
            return icalproperty_new_transp(ICAL_TRANSP_OPAQUE)
        default:
            return icalproperty_new_transp(ICAL_TRANSP_TRANSPARENT)
        }
    }
}

public struct VEvent {
    public init(summary: String, dtstamp: Date = Date(), dtstart: DateComponents, dtend: DateComponents? = nil) {
        self.summary = summary
        self.dtstamp = dtstamp
        self.dtstart = dtstart
        self.dtend = dtend
    }
    
    public var useTZIDPrefix = true

    /// A short summary or subject for the calendar component.
    ///
    /// See [RFC 5543 Section 3.8.1.12](https://tools.ietf.org/html/rfc5545#section-3.8.1.12) for details.
    public var summary: String? = nil

    public var description: String?

    // dtstamp must be in UTC
    public var dtstamp: Date

    /// Start time of the event
    public var dtstart: DateComponents

    /// End time of the event
    public var dtend: DateComponents?

    public var uid: String = UUID().uuidString

    public var created: Date = Date()
    
    public var recurranceRule: RecurranceRule?
    
    public var duration: Duration?

    public var attendees: [Attendee]? = nil

    public var organizer: Organizer? = nil

    public var transparency: Transparency = .opaque
    
    public var alarm: VAlarm? = nil
    
    /// Custom X properties
    public var xProperties: [String: String] = [:]
}

extension VEvent: LibicalComponentConvertible {
    func libicalComponent() -> LibicalComponent {
        let comp = icalcomponent_new_vevent()

        let dtstampProperty = icalproperty_new_dtstamp(dtstamp.icalTime(timeZone: .utc))
        icalcomponent_add_property(comp, dtstampProperty)

        let dtstartProperty = icalproperty_new_dtstart(dtstart.date!.icalTime(timeZone: dtstart.timeZone ?? .utc))

        if let timezone = dtstart.timeZone {
            if useTZIDPrefix {
                icalproperty_add_parameter(dtstartProperty, icalparameter_new_tzid(String(cString: icaltimezone_tzid_prefix()!) + timezone.identifier))
            } else {
                icalproperty_add_parameter(dtstartProperty, icalparameter_new_tzid(timezone.identifier))
            }
        }
        icalcomponent_add_property(comp, dtstartProperty)

        if let dtend = dtend {
            let dtendProperty = icalproperty_new_dtend(dtend.date!.icalTime(timeZone: dtend.timeZone ?? .utc))
            if let timezone = dtend.timeZone {
                if useTZIDPrefix {
                    icalproperty_add_parameter(dtendProperty, icalparameter_new_tzid(String(cString: icaltimezone_tzid_prefix()!) + timezone.identifier))
                } else {
                    icalproperty_add_parameter(dtendProperty, icalparameter_new_tzid(timezone.identifier))
                }
            }
            icalcomponent_add_property(comp, dtendProperty)
        }
        
        if let duration = duration {
            let duration = icaldurationtype(is_neg: 0, days: UInt32(duration.days), weeks: UInt32(duration.weeks), hours: UInt32(duration.hours), minutes: UInt32(duration.minutes), seconds: UInt32(duration.seconds))
            icalcomponent_add_property(comp, icalproperty_new_duration(duration))
        }

        icalcomponent_add_property(comp, icalproperty_new_summary(summary))
        icalcomponent_add_property(comp, icalproperty_new_uid(uid))
        if let description = description {
            icalcomponent_add_property(comp, icalproperty_new_description(description))
        }

        icalcomponent_add_property(comp, transparency.libicalProperty())
        icalcomponent_add_property(comp, icalproperty_new_created(created.icalTime(timeZone: .utc)))

        attendees?.forEach({ (attendee) in
            icalcomponent_add_property(comp, attendee.libicalProperty())
        })

        if let organizer = organizer {
            icalcomponent_add_property(comp, organizer.libicalProperty())
        }
        
        if let alarm = alarm {
            icalcomponent_add_component(comp, alarm.libicalComponent())
        }
        
        for xProperty in xProperties {
            let param = icalproperty_new_x(xProperty.value)
            icalproperty_set_x_name(param, xProperty.key)
            icalcomponent_add_property(comp, param)
        }
        
        return comp!
    }
}

public struct Duration {
    public let seconds: Int
    public let minutes: Int
    public let hours: Int
    public let days: Int
    public let weeks: Int
    
    public init(seconds: Int, minutes: Int, hours: Int, days: Int, weeks: Int) {
        self.seconds = seconds
        self.minutes = minutes
        self.hours = hours
        self.days = days
        self.weeks = weeks
    }
}

public enum AlarmTrigger {
    case duration(duration: Duration)
    case time(date: DateComponents)
}

public struct AlarmFrequent {
    let frequent: Int
    let duration: Duration
}

public enum AlarmAction {
    case display(description: String)
    case email(summary: String, description: String, attendees: [Attendee])
}

public struct VAlarm {
    public var trigger: AlarmTrigger
    public var action: AlarmAction
    public var frequent: AlarmFrequent?
    
    public init(trigger: AlarmTrigger, action: AlarmAction) {
        self.trigger = trigger
        self.action = action
    }
}

extension VAlarm: LibicalComponentConvertible {
    func libicalComponent() -> LibicalComponent {
        let alarm = icalcomponent_new_valarm()
        
        var triggertype = icaltriggertype()
        switch trigger {
        case .duration(duration: let duration):
            let duration = icaldurationtype(is_neg: 1, days: UInt32(duration.days), weeks: UInt32(duration.weeks), hours: UInt32(duration.hours), minutes: UInt32(duration.minutes), seconds: UInt32(duration.seconds))
            triggertype.duration = duration
            triggertype.time = icaltime_null_time()
        case .time(date: let date):
            triggertype.duration = icaldurationtype_null_duration()
            triggertype.time = date.date!.icalTime(timeZone: date.timeZone ?? .utc)
        }
        
        let trigger = icalproperty_new_trigger(triggertype)
        icalcomponent_add_property(alarm, trigger)
        
        switch action {
        case .display(description: let description):
            icalcomponent_add_property(alarm, icalproperty_new_action(ICAL_ACTION_DISPLAY));
            icalcomponent_add_property(alarm, icalproperty_new_description(description));
        case .email(summary: let summary, description: let description, attendees: let attendees):
            icalcomponent_add_property(alarm, icalproperty_new_action(ICAL_ACTION_EMAIL));
            icalcomponent_add_property(alarm, icalproperty_new_summary(summary));
            icalcomponent_add_property(alarm, icalproperty_new_description(description));
            attendees.forEach({ (attendee) in
                icalcomponent_add_property(alarm, attendee.libicalProperty())
            })
        }
        
        if let frequent = frequent {
            let duration = icaldurationtype(is_neg: 0, days: UInt32(frequent.duration.days), weeks: UInt32(frequent.duration.weeks), hours: UInt32(frequent.duration.hours), minutes: UInt32(frequent.duration.minutes), seconds: UInt32(frequent.duration.seconds))
            icalcomponent_add_property(alarm, icalproperty_new_duration(duration))
            icalcomponent_add_property(alarm, icalproperty_new_repeat(Int32(frequent.frequent)));
        }
        
        return alarm!
    }
}
