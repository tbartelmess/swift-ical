# Swift-iCal

Library to generate [iCalendar](https://tools.ietf.org/html/rfc5545#section-3.8.7.4) objects using Swift.




## Dates and DateComponents

Most dates in SwiftIcal are represented using Foundations [`DateComponents`](https://developer.apple.com/documentation/foundation/datecomponents), and not using a [`Date` ](https://developer.apple.com/documentation/foundation/date).
Date Components represent a date within a calendar and a timezone.
Currently Swift-iCal only support the [Gregorian calendar](https://en.wikipedia.org/wiki/Gregorian_calendar).

For your convenience, Swift-iCal adds an extension to `Date` to get the date components in a given timezone.

```swift

let myDate = Date()

# Get a in the current system timezone
let myComponents = myDate.components()

# Get components in a specific timezone
let timezone = TimeZone(identifier: "America/Toronto")
let myComponents = myDate.components(timezone: timezone)
```

## Creating a VEVENT

All events need to be wrapped into a `VCALENDAR`.


```swift
let timezone = TimeZone(identifier: "America/Toronto")


let start = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                           timeZone: timezone,
                           year: 2020,
                           month: 5,
                           day: 9,
                           hour: 22,
                           minute: 0,
                           second: 0)

let end = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                         timeZone: timezone,
                         year: 2020,
                         month: 5,
                         day: 9,
                         hour: 23,
                         minute: 0,
                         second: 0)

let event = VEvent(summary: "Hello World", dtstart: start, dtend: end)
var calendar = VCalendar()
calendar.events.append(event)
print(calendar.icalString())
```

This will generate a `VCalendar` similar to

```ics
BEGIN:VCALENDAR
PRODID:-//SwiftIcal/EN
VERSION:2.0
BEGIN:VTIMEZONE
.....
END:VTIMEZONE
BEGIN:VEVENT
DTSTAMP:20200510T000730Z
DTSTART;TZID=America/Toronto:20200509T220000
DTEND;TZID=America/Toronto:20200509T230000
SUMMARY:Hello World
UID:14490209-562F-4A52-8E42-4020A168ECD7
TRANSP:OPAQUE
CREATED:20200510T000730Z
END:VEVENT
END:VCALENDAR
```

### Timezones

SwiftIcal uses the timezones from the timezone database.
By default all required timezones are included in a generated VCalendar.

## License

### Swift Bindings

Swift-iCal is licenced under The Mozilla Public License 2.0.

### Libical


libical is distributed under two licenses.
You may choose the terms of either:

 * The Mozilla Public License (MPL) v2.0

 or

 * The GNU Lesser General Public License (LGPL) v2.1

----------------------------------------------------------------------

Software distributed under these licenses is distributed on an "AS
IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
implied. See the License for the specific language governing rights
and limitations under the License.
Libical is distributed under both the LGPL and the MPL. The MPL
notice, reproduced below, covers the use of either of the licenses.

----------------------------------------------------------------------

