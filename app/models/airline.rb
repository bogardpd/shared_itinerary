class Airline < ActiveRecord::Base
  has_many :flights
  before_save { self.iata_code = iata_code.upcase }
  validates :iata_code, presence: true,
                        length: { is: 2 },
                        uniqueness: { case_sensitive: false }
  
  def formatted_name
    self.name ? self.name : self.iata_code
  end
  
end
