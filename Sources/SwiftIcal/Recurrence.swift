import Foundation
import CLibical

public typealias Second = Int
public typealias Minute = Int
public typealias Hour = Int
public typealias Day = Int
public typealias MonthDay = Int
public typealias YearDay = Int
public typealias WeekNumber = Int
public typealias Month = Int
public typealias Setpos = Int

/// RecurrenceRule
///
/// Recurrence Rules describe  a rule or repeating pattern for recurring events, to-dos, journal entries, or time zone definitions.
///
public struct RecurrenceRule {

    /// Options for the repeat frequency of a `RecurrenceRule`.
    ///
    /// See [RFC 5545 Section 3.3.10](https://tools.ietf.org/html/rfc5545#section-3.3.10) for more details.
    public enum Frequency {

        /// Repeat every second
        case secondly

        /// Repeat every minute
        case minutely

        /// Repeat every hour
        case hourly

        /// Repeat every day
        case daily

        /// Repeat every week
        case weekly

        /// Repeat every month
        case monthly

        /// Repeat every year
        case yearly
    }

    public enum Weekday {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    public enum Month: Int {
        case january = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
    }


    /// Describes how long an event, todo, journal entry or timezone definition should be repeated for
    public enum RecurrenceEnd {

        /// No defined end, the event will repeat forever
        case never

        /// End after a defined number of occurrences
        case count(Int)

        /// End after a given date
        case date(DateComponents)
    }

    /// Creates a new `RecurrenceRule`
    ///
    /// - parameter frequency: Repeat frequency for the repeat rule. See `RecurrenceRule.Frequency` for options.
    /// - parameter until: Rule how often or until when the event, todo, journal entry or timezone definition should be repeated
    public init(frequency: Frequency, until: RecurrenceEnd = .never) {
        self.frequency = frequency
        self.until = until
    }

    public var frequency: Frequency
    public var until: RecurrenceEnd

    /// Interval at which intervals the recurrence rule repeats
    ///
    /// The default value is
    /// "1", meaning every second for a SECONDLY rule, every minute for a
    /// MINUTELY rule, every hour for an HOURLY rule, every day for a
    /// DAILY rule, every week for a WEEKLY rule, every month for a
    /// MONTHLY rule, and every year for a YEARLY rule.  For example,
    /// within a DAILY rule, a value of "8" means every eight days.
    public var interval: Int = 1

    public var bySecond = Set<Second>()
    public var byMinute = Set<Minute>()
    public var byHour = Set<Hour>()
    public var byDay = Set<Day>()
    public var byMonthDay = Set<MonthDay>()
    public var byYearDay = Set<YearDay>()
    public var byWeekNumber = Set<WeekNumber>()
    public var byMonth = Set<Month>()
    public var bySetpos = Set<Setpos>()

}

extension RecurrenceRule.Frequency {
    var icalFrequency: icalrecurrencetype_frequency {
        switch self {
        case .secondly:
            return ICAL_SECONDLY_RECURRENCE
        case .minutely:
            return ICAL_MINUTELY_RECURRENCE
        case .hourly:
            return ICAL_HOURLY_RECURRENCE
        case .daily:
            return ICAL_DAILY_RECURRENCE
        case .weekly:
            return ICAL_WEEKLY_RECURRENCE
        case .monthly:
            return ICAL_MONTHLY_RECURRENCE
        case .yearly:
            return ICAL_YEARLY_RECURRENCE
        }
    }
}

extension RecurrenceRule.Weekday {
    var icalRecurrenceWeekday:icalrecurrencetype_weekday {
        switch self {
        case .sunday:
            return ICAL_SUNDAY_WEEKDAY
        case .monday:
            return ICAL_MONDAY_WEEKDAY
        case .tuesday:
            return ICAL_TUESDAY_WEEKDAY
        case .wednesday:
            return ICAL_WEDNESDAY_WEEKDAY
        case .thursday:
            return ICAL_THURSDAY_WEEKDAY
        case .friday:
            return ICAL_FRIDAY_WEEKDAY
        case .saturday:
            return ICAL_SATURDAY_WEEKDAY
        }
    }
}

extension Sequence where Element == Int {
    var libicalRecurrenceSequence: [Int16] {
        var elements = sorted().map { Int16($0) }
        elements.append(Int16(ICAL_RECURRENCE_ARRAY_MAX.rawValue))
        return elements
    }

    func copyToLibicalStruct<T>( foo: inout T) {
        withUnsafeMutableBytes(of: &foo) { (ptr) in
            ptr.bindMemory(to: Int16.self)
            let _ = ptr.initializeMemory(as: Int16.self, from: libicalRecurrenceSequence)
        }
    }
}

extension RecurrenceRule: LibicalPropertyConvertible {
    func libicalProperty() -> LibicalProperty {
        var recurrence = icalrecurrencetype()
        recurrence.freq = frequency.icalFrequency
        recurrence.interval = Int16(interval)

        switch self.until {
        case .count(let count):
            recurrence.count = Int32(count)
        case .date(let components):
            recurrence.until = components.icaltime
        default:
            break
        }

        bySecond.copyToLibicalStruct(foo: &recurrence.by_second)
        byMinute.copyToLibicalStruct(foo: &recurrence.by_minute)
        byHour.copyToLibicalStruct(foo: &recurrence.by_hour)
        byDay.copyToLibicalStruct(foo: &recurrence.by_day)
        byMonthDay.copyToLibicalStruct(foo: &recurrence.by_month_day)
        byYearDay.copyToLibicalStruct(foo: &recurrence.by_year_day)
        byWeekNumber.copyToLibicalStruct(foo: &recurrence.by_week_no)
        byMonth.map({ $0.rawValue }).copyToLibicalStruct(foo: &recurrence.by_month)
        bySetpos.copyToLibicalStruct(foo: &recurrence.by_set_pos)
        return icalproperty_new_rrule(recurrence)
    }




}
