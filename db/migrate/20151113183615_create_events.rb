class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :event_name
      t.text :arriving_timezone
      t.text :departing_timezone
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
