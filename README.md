# Shared Itinerary

**[https://www.shareditinerary.com](https://www.shareditinerary.com)**

[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000?style=plastic)](https://github.com/bogardpd/shared_itinerary/blob/master/LICENSE.md)

[Shared Itinerary](https://www.shareditinerary.com) is a Ruby on Rails application for visualizing multiple people's flight times. It's intended to help people who are coordinating travel for an event (and the event's attendees) see what times everyone is arriving and departing. This could be used to coordinate shared airport transportation, or just so guests know when to expect other guests.

Shared Itinerary is written and maintained by [Paul Bogard](https://www.pbogard.com/).

## Events

Users start by creating an event. By default, only the person who creates an event can see it. However, the event creator can give out a share link which will allow anyone with the link to view the event without logging in.

## Itineraries

The event creator can then add itineraries to an event. An itinerary contains all of a user's flights and layovers going in a particular direction (for example, all flights on their trip to the event, or all flights on their trip home).

## Charts

Once the creator has added some itineraries, Shared Itinerary will automatically generate a chart showing visually when people are arriving and departing. The horizontal axis of the chart shows a 24-hour day, and the vertical axis shows different travelers. If multiple days of travel are needed, charts will be shown for multiple days. Itineraries, flights, and layovers can span multiple days if needed!

If travelers are arriving to the event at different airports, or departing the event from different airports, the itineraries will be color-coded by airport.  Arriving travelers are sorted by arrival airport and then arrival time, and travelers going home are sorted by departure airport and then departure time. This makes it very easy to see which travelers will be at the same airport at the same time.

## Sample Event

Please see this [sample event](https://www.shareditinerary.com/events/1/share/089f040a3616898d), which has an example of the kind of charts that Shared Itinerary can create!


