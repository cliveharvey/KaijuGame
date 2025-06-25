class Soldier
  CONSONANTS = %w[b c d f g h j k l m n p q r s sh zh t v w x].freeze
  VOWELS = %w[a e i o u ae y].freeze

  attr_accessor :name, :skill, :status, :success

  def initialize(name_length = rand(3..8), skill = rand(10..35))
    @name = generate_name(name_length)
    @skill = skill
    @status = :alive
    @success = false
  end

  def combat(difficulty)
    combat_roll = rand(@skill)

    case combat_roll
    when 0..(difficulty - 30)
      @status = :kia
      false
    when (difficulty - 30)..(difficulty - 20)
      @status = :injured
      @skill += difficulty / 2
      false
    when (difficulty - 20)..(difficulty - 10)
      @status = :shaken
      @skill += difficulty / 2
      @success = true
    else
      @skill += difficulty
      @success = true
    end
  end

  private

  def generate_name(length)
    name = CONSONANTS.sample.capitalize + VOWELS.sample
    (length - 2).times do |i|
      name += i.even? ? CONSONANTS.sample : VOWELS.sample
    end
    name
  end
end
