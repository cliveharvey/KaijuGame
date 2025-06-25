require_relative 'soldier'

class Squad
  attr_reader :name, :soldiers

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5)
    @name = name
    @soldiers = soldier_count.times.map { Soldier.new }
  end

  def combat(difficulty)
    @soldiers.each { |soldier| soldier.combat(difficulty) }
    @soldiers.count(&:success) >= 3
  end
end
