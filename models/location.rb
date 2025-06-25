class Location
  CITIES = [
    "Prague, Czech Republic", "Istanbul, Turkey", "Jerusalem, Israel",
    "Accra, Ghana", "Colombo, Sri Lanka", "Buenos Aires, Argentina",
    "Reykjavík, Iceland", "Denver, United States", "Abuja, Nigeria",
    "Nashville, TN, United States", "Bratislava, Slovakia", "Lima, Peru"
  ].freeze

  attr_reader :city

  def initialize
    @city = CITIES.sample
  end
end
