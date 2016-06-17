class Section < ActiveRecord::Base
  belongs_to :event
  has_many :flights, dependent: :destroy
  validates :event_id, presence: true
  validates :traveler_name, presence: true
  
  def timezone
    self.is_arrival? ? self.event.arriving_timezone : self.event.departing_timezone
  end
end
