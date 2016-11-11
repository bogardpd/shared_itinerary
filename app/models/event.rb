class Event < ActiveRecord::Base
  belongs_to :user
  has_many :sections, dependent: :destroy
  validates :user_id, presence: true
  validates :event_name, presence: true
  validates :timezone, presence: true
  
  # Return this event's Chart object.
  def chart
    return Chart.new(self)
  end
  
  # Return a hash of departures and arrivals, with :arrivals or :departures as
  # the keys and arrays of sections as the values.
  def event_sections
    section_hash = Hash.new
    arrivals = Array.new
    departures = Array.new
    self.sections.each do |section|
      if section.is_arrival?
        flight_list = section.flights.order(:arrival_datetime)
        flight_any = (flight_list.length > 0)
        arrivals.push(  section:     section,
                         flights:     flight_list,
                         key_airport: flight_any ? flight_list.last.arrival_airport : Airport.new,
                         key_iata:    flight_any ? flight_list.last.arr_airport_iata : "",
                         key_time:    flight_any ? flight_list.last.arrival_datetime : nil,
                         alt_time:    flight_any ? flight_list.first.departure_datetime : nil)
      else
        flight_list = section.flights.order(:departure_datetime)
        flight_any = (flight_list.length > 0)
        departures.push(section:     section,
                         flights:     flight_list,
                         key_airport: flight_any ? flight_list.first.departure_airport : Airport.new,
                         key_iata:    flight_any ? flight_list.first.dep_airport_iata : "",
                         key_time:    flight_any ? flight_list.first.departure_datetime : nil,
                         alt_time:    flight_any ? flight_list.last.arrival_datetime : nil)
      end
    end
    arrivals.sort_by!   { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    departures.sort_by! { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    section_hash[:arrivals]   = arrivals
    section_hash[:departures] = departures
    return section_hash
  end
  
end