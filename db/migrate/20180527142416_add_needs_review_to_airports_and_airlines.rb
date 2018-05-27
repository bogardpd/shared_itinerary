class AddNeedsReviewToAirportsAndAirlines < ActiveRecord::Migration[5.2]
  def change
    add_column :airlines, :needs_review, :boolean, default: false
    add_column :airports, :needs_review, :boolean, default: false
  end
end
