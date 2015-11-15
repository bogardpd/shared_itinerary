class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.text :traveler_name
      t.text :traveler_note
      t.text :pickup_info
      t.boolean :is_arrival

      t.timestamps null: false
    end
  end
end
