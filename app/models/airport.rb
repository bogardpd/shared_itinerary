class Airport < ActiveRecord::Base
  has_many :departing_flights, :class_name => 'Flight', :foreign_key => 'departure_airport_id'
  has_many :arriving_flights, :class_name => 'Flight', :foreign_key => 'arrival_airport_id'
  
  before_save { self.iata_code = iata_code.upcase }
  validates :iata_code, presence: true,
                        length: { is: 3 },
                        uniqueness: { case_sensitive: false }
                        
  def formatted_name
    self.name ? "#{self.name} (#{self.iata_code})" : self.iata_code
  end
  
  def formatted_iata
    self.iata_code ? self.iata_code : ""
  end
  
end
