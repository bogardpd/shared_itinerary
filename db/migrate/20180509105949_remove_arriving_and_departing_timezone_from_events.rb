class RemoveArrivingAndDepartingTimezoneFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :arriving_timezone, :text
    remove_column :events, :departing_timezone, :text
  end
end
