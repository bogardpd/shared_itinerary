class Section < ActiveRecord::Base
  belongs_to :event
  has_many :flights, dependent: :destroy
  validates :event_id, presence: true
  validates :traveler_name, presence: true
end
