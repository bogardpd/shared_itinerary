# Shared Itinerary [DEPRECATED]

**[https://www.shareditinerary.com](https://www.shareditinerary.com)**

[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000?style=plastic)](https://github.com/bogardpd/shared_itinerary/blob/master/LICENSE.md)

[Shared Itinerary](https://www.shareditinerary.com) is a Ruby on Rails application for visualizing multiple people's flight times. It's intended to help people who are coordinating travel for an event (and the event's attendees) see what times everyone is arriving and departing. This could be used to coordinate shared airport transportation, or just so guests know when to expect other guests.

Shared Itinerary is written and maintained by [Paul Bogard](https://www.pbogard.com/).

## Sample Event

Please see this [sample event](https://www.shareditinerary.com/events/1/share/089f040a3616898d), which has an example of the kind of charts that Shared Itinerary can create!

## Version History

| Date | Version | Memo |
| ----:| ------- | ---- |
| (In progress) |     | Add timezones and flight search |
|  5 Oct 2016 | 0.2 | Move chart code to `Chart` class |
| 19 Jun 2016 | 0.1 | Initial beta release |

## Models

### Airline

| Parameter      | Type    | Required? | Purpose |
| ------------   | ------- | --------- | ------- |
| `iata_code`    | string  | No        | IATA code |
| `icao_code`    | string  | No        | ICAO code |
| `name`         | string  | No        | Name (shortened when possible, e.g. "American" instead of "American Airlines") |
| `needs_review` | boolean | No        | `true` if airline was automatically created and has not yet been reviewed by an admin; `false` if airline was reviewed by or manually created by an admin |

| Relationship | Models |
| ------------ | ------ |
| has many     | [`Flights`](#flight) |

An `Airline` is an airline which can be associated with flights. If a new flight has an airline which is not yet in the database, the new airline will generally be created with as much data is available from the New Flight form and from [FlightXML](#flightxml). Airlines that are automatically created should set `needs_review` to `true`. When the airline is edited by an admin, `needs_review` will be set to `false`.

### Airport

| Parameter      | Type    | Required? | Purpose |
| ------------   | ------- | --------- | ------- |
| `iata_code`    | string  | No        | IATA code |
| `icao_code`    | string  | No        | ICAO code |
| `name`         | string  | No        | Metro area served by the airport |
| `timezone`     | string  | Yes       | IANA Timezone string for the airport's location |
| `needs_review` | boolean | No        | `true` if airport was automatically created and has not yet been reviewed by an admin; `false` if airport was reviewed by or manually created by an admin |

| Relationship | Models |
| ------------ | ------ |
| has many     | `origin_flights` ([`Flight`](#flight)), `destination_flights` ([`Flight`](#flight)) |

An `Airport` is an airport which can be associated with flights. If a new flight has an airport which is not yet in the database, the new airport will generally be created with as much data is available from the New Flight form and from [FlightXML](#flightxml). Airports that are automatically created should set `needs_review` to `true`. When the airport is edited by an admin, `needs_review` will be set to `false`.

### Event

| Parameter    | Type    | Required? | Purpose |
| ------------ | ------- | --------- | ------- |
| `event_name` | string  | Yes       | Event name |
| `note`       | string  | No        | Additional details about the event (supports Markdown) |
| `share_link` | string  | No        | Hexadecimal string used to gain read-only access to the event |
| `timezone`   | string  | No        | IANA Timezone string for the location the event takes place. If blank, `Etc/UTC` will be used. |
| `city`       | string  | No        | The city that the event takes place in |
| `user_id`    | integer | Yes       | [`User`](#user) that owns the event |

| Relationship | Models |
| ------------ | ------ |
| belongs to   | [`User`](#user) |
| has many     | [`Travelers`](#traveler) |

An `Event` is the basic building block for Shared Itinerary, representing a single event which multiple people can be traveling to and from.

By default, only the [`User`](#user) who created an event can view or edit the event, its [`Travelers`](#traveler), and its travelers' [`Flights`](#flight). However, each event has a share link which, when provided as a parameter, will allow view-only access to the event, its [`Travelers`](#traveler), and its travelers' [`Flights`](#flight).

### Flight

| Parameter                | Type     | Required? | Purpose |
| ------------------------ | -------- | --------- | ------- |
| `airline_id`             | integer  | Yes       | [`Airline`](#airline) marketing this flight |
| `destination_airport_id` | integer  | Yes       | Arrival [`Airport`](#airport) |
| `destination_time`       | datetime | Yes       | Arrival time (UTC) |
| `flight_number`          | integer  | Yes       | Flight number |
| `is_event_arrival`       | boolean  | Yes       | `true` if this flight takes the traveler to the event; `false` if this flight takes the traveler home from the event |
| `origin_airport_id`      | integer  | Yes       | Departure [`Airport`](#airport) |
| `origin_time`            | datetime | Yes       | Departure time (UTC) |
| `traveler_id`            | integer  | Yes       | [`Traveler`](#traveler) that is taking this flight |

| Relationship | Models |
| ------------ | ------ |
| belongs to   | [`Traveler`](#traveler), [`Airline`](#airline), `origin_airport` ([`Airport`](#airport)) `destination_airport` ([`Airport`](#airport)) |

A `Flight` is a single flight that a [`Traveler`](#traveler) uses to get to or from an [`Event`](#event). A traveler may have zero or more flights in each direction; traveler itineraries with layovers should list each flight segment as a separate `Flight`.

Even if multiple travelers are taking the same flight, each traveler's flight is a separate `Flight` instance associated with that [`Traveler`](#traveler).

### Traveler

| Parameter        | Type    | Required? | Purpose |
| ---------------- | ------- | --------- | ------- |
| `arrival_info`   | string  | No        | Details for how the traveler will get from the airport to the event |
| `contact_info`   | string  | No        | Details for how to contact the traveler |
| `departure_info` | string  | No        | Details for how the traveler will get from the event to the airport |
| `event_id`       | integer | Yes       | [`Event`](#event) that this traveler is attending |
| `traveler_name`  | string  | Yes       | Traveler name |
| `traveler_note`  | string  | No        | Traveler supplemental information (nickname, department, etc.) |

| Relationship | Models |
| ------------ | ------ |
| belongs to   | [`Event`](#event) |
| has many     | [`Flights`](#flight) |

A `Traveler` is a person who is attending an event. Each traveler can have zero or more flights associated with the event.

Travelers are unique to events; if an individual is traveling to multiple events, they will have a separate `Traveler` instance for each `Event`.

### User

| Parameter         | Type    | Required? | Purpose |
| ----------------- | ------- | --------- | ------- |
| `admin`           | boolean | Yes       | `true` if user is an admin, `false` otherwise |
| `email`           | string  | Yes       | Email address (also used as unique identifier to log in) |
| `name`            | string  | Yes       | Name |
| `password_digest` | string  | Yes       | Password hash |
| `remember_digest` | string  | No        | Hash used for "remember me" functionality when logging in |

| Relationship | Models |
| ------------ | ------ |
| has many     | [`Events`](#event) |

A `User` is somebody who can log in to Shared Itinerary, create [events](#event), add [travelers](#traveler) to those events, and add [flights](#flight) to those travelers. They can also edit existing events, travelers, and flights that belong to them.

Even though a user may also be a traveler on their own event, `User` is distinct from `Traveler`, so they must actually add themselves as a `Traveler` instance.

Admins have the additional ability to list and delete users, and to edit [airlines](#airline) and [airports](#airport).

## Classes

### Chart

`Chart` is a class designed to generate a graphical depiction of when people are arriving at and departing from an [`Event`](#event), based on the [`Traveler`](#traveler) and travelers' [`Flight`](#flight) data associated with the event. 

The chart can be initialized by calling `Chart.new(Event)`. A shortcut `Event.chart` instance method is also available. Once a chart instance has been created, `Chart.draw` can be used to return the chart drawing as an inline SVG string.

The horizontal axis of the chart shows a day from 00:00 to 24:00 in `Event.timezone` (usually 24 hours, but more or fewer hours as appropriate if daylight savings status changes during the day), and the vertical axis shows different travelers. If multiple days of travel are needed, charts will be shown for multiple days. Traveler tineraries, flights, and layovers can span multiple days if needed.

If travelers are arriving to the event at different airports, or departing the event from different airports, the travelers' itineraries will be color-coded by arrival airport (for each traveler's latest arrival flight) and by departure airport (for each traveler's earliest departure flight).  Arriving travelers are sorted by arrival airport and then arrival time, and travelers going home are sorted by departure airport and then departure time. This makes it easy to see which travelers will be at the same airport at the same time.

## Modules

### External Image

The `ExternalImage` module holds the root path for the AWS S3 folder where images used by Shared Itinerary are stored.

### FlightXML

The `FlightXML` module allows SharedItinerary to interact with [FlightAware](https://flightaware.com/)'s [FlightXML 2.0 API](https://flightaware.com/commercial/flightxml/documentation2.rvt) to search for [`Flights`](#flight) and to look up information for new [`Airports`](#airport) and [`Airlines`](#airline).

### Timezones

The `Timezones` module provides some supplemental methods for dealing with timezone data (beyond what is already provided by `TZInfo` and the Ruby/Rails `Time` class).