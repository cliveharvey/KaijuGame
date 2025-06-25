class Soldier
  CONSONANTS = %w[b c d f g h j k l m n p q r s sh zh t v w x].freeze
  VOWELS = %w[a e i o u ae y].freeze

  attr_accessor :name, :offense, :defense, :grit, :leadership, :status, :success

  def initialize(name_length = rand(3..8), offense = rand(10..30), defense = rand(10..30), grit = rand(10..30), leadership = rand(10..30))
    @name = generate_name(name_length)
    @offense = offense
    @defense = defense
    @grit = grit
    @leadership = leadership
    @status = :alive
    @success = false
  end

  def combat(difficulty)
    # Calculate combat effectiveness based on multiple skills
    attack_power = @offense + (@leadership / 2)  # Leadership helps coordinate attacks
    survival_chance = @defense + (@grit / 2)     # Grit helps with defense

    # Roll for attack success
    attack_roll = rand(attack_power)
    # Roll for survival/defense
    defense_roll = rand(survival_chance)

    # More balanced combat thresholds
    case attack_roll
    when 0..(difficulty - 20)
      # Poor attack - outcome depends on defense
      if defense_roll < (difficulty - 15)
        @status = :kia
        false
      else
        @status = :injured
        improve_skills(difficulty / 3)
        false
      end
    when (difficulty - 20)..(difficulty - 10)
      # Decent attack
      if defense_roll < (difficulty - 10)
        @status = :injured
        improve_skills(difficulty / 2)
        @success = true
      else
        @status = :shaken
        improve_skills(difficulty / 2)
        @success = true
      end
    when (difficulty - 10)..(difficulty)
      # Good attack
      if defense_roll < (difficulty - 5)
        @status = :shaken
        improve_skills(difficulty)
        @success = true
      else
        improve_skills(difficulty)
        @success = true
      end
    else
      # Excellent attack
      improve_skills(difficulty + 5)
      @success = true
    end
  end

  def total_skill
    @offense + @defense + @grit + @leadership
  end

  def skill_summary
    "O:#{@offense} D:#{@defense} G:#{@grit} L:#{@leadership}"
  end

  private

  def improve_skills(experience_gain)
    # Distribute experience across skills based on performance
    base_gain = [1, experience_gain / 4].max
    @offense += rand(1..base_gain)
    @defense += rand(1..base_gain)
    @grit += rand(1..base_gain)
    @leadership += rand(1..base_gain)
  end

  def generate_name(length)
    name = CONSONANTS.sample.capitalize + VOWELS.sample
    (length - 2).times do |i|
      name += i.even? ? CONSONANTS.sample : VOWELS.sample
    end
    name
  end
end
