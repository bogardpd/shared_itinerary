class ChangeTravelerPickupInfoToArrivalInfoAndDepartureInfo < ActiveRecord::Migration[5.2]
  def change
    rename_column :travelers, :pickup_info, :arrival_info
    add_column :travelers, :departure_info, :text
  end
end
