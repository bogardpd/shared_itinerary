class Event < ActiveRecord::Base
  belongs_to :user
  has_many   :travelers, dependent: :destroy
  
  validates :user_id, presence: true
  validates :event_name, presence: true
  validates :arriving_timezone, presence: true
  validates :departing_timezone, presence: true
  
  # Return this event's Chart object.
  def chart
    return Chart.new(self)
  end
  
  # Return a hash of departures and arrivals, with :arrivals or :departures as
  # the keys and arrays of travelers as the values.
  def event_travelers
    traveler_hash = Hash.new
    arrivals = Array.new
    departures = Array.new
    self.travelers.each do |traveler|
      if traveler.is_arrival?
        flight_list = traveler.flights.order(:arrival_datetime)
        flight_any = (flight_list.length > 0)
        arrivals.push(  traveler:     traveler,
                         flights:     flight_list,
                         key_airport: flight_any ? flight_list.last.arrival_airport : Airport.new,
                         key_iata:    flight_any ? flight_list.last.arr_airport_iata : "",
                         key_time:    flight_any ? flight_list.last.arrival_datetime : nil,
                         alt_time:    flight_any ? flight_list.first.departure_datetime : nil,
                         pickup_info: traveler.pickup_info)
      else
        flight_list = traveler.flights.order(:departure_datetime)
        flight_any = (flight_list.length > 0)
        departures.push(traveler:     traveler,
                         flights:     flight_list,
                         key_airport: flight_any ? flight_list.first.departure_airport : Airport.new,
                         key_iata:    flight_any ? flight_list.first.dep_airport_iata : "",
                         key_time:    flight_any ? flight_list.first.departure_datetime : nil,
                         alt_time:    flight_any ? flight_list.last.arrival_datetime : nil,
                         pickup_info: traveler.pickup_info)
      end
    end
    arrivals.sort_by!   { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    departures.sort_by! { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    traveler_hash[:arrivals]   = arrivals
    traveler_hash[:departures] = departures
    return traveler_hash
  end
  
  # Temporary method to merge departure and arrival travelers with the same name
  # in the same event into a single traveler.
  def consolidate_travelers
    event_flights = Flight.joins(:traveler).where("travelers.event_id = ?", self.id)
    traveler_ids = self.travelers.pluck(:id).sort
    unique_names = self.travelers.pluck(:traveler_name).uniq
    unique_names.each do |name|
      traveler_flights = event_flights.where("travelers.traveler_name = ?", name)
      traveler_ids = traveler_flights.pluck(:traveler_id).uniq.sort
      new_traveler_id = traveler_ids.first
      delete_traveler_ids = traveler_ids[1..-1]
      puts "#{name} (#{traveler_ids} / Keep #{new_traveler_id}, delete #{delete_traveler_ids}): #{traveler_flights.pluck(:id)}"

      traveler_flights.update_all(traveler_id: new_traveler_id)
      Traveler.where(id: delete_traveler_ids).destroy_all
    end
  end
  
end