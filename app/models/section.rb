class Section < ActiveRecord::Base
  belongs_to :event
  validates :event_id, presence: true
  validates :traveler_name, presence: true
end
