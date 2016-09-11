class Event < ActiveRecord::Base
  belongs_to :user
  has_many :sections, dependent: :destroy
  validates :user_id, presence: true
  validates :event_name, presence: true
  validates :arriving_timezone, presence: true
  validates :departing_timezone, presence: true
  
  def chart
    return Chart.new(self)
  end
  
end