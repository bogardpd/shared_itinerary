class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.text        :airline_iata
      t.integer     :flight_number
      t.datetime    :departure_datetime
      t.text        :departure_airport_iata
      t.datetime    :arrival_datetime
      t.text        :arrival_airport_iata
      t.timestamps  null: false
    end
  end
end
