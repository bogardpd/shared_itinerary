class RenameFlightDepartureAndArrivalToOriginAndDestination < ActiveRecord::Migration[5.2]
  def change
    rename_column :flights, :departure_datetime, :origin_time
    rename_column :flights, :arrival_datetime, :destination_time
    rename_column :flights, :departure_airport_id, :origin_airport_id
    rename_column :flights, :arrival_airport_id, :destination_airport_id
    rename_column :flights, :is_arrival, :is_event_arrival
  end
end
