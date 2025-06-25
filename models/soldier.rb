require_relative '../generators/soldier_name_generator'

class Soldier
  attr_accessor :name, :offense, :defense, :grit, :leadership, :status, :success

  def initialize(name_length = nil, offense = rand(10..30), defense = rand(10..30), grit = rand(10..30), leadership = rand(10..30))
    @name = SoldierNameGenerator.generate_name
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

    # Weakness penalty for low-skill soldiers
    total_skill = @offense + @defense + @grit + @leadership
    weakness_penalty = 0

    if total_skill < 60  # Very weak soldiers (bottom ~15%)
      weakness_penalty = 10
    elsif total_skill < 70  # Weak soldiers (bottom ~35%)
      weakness_penalty = 5
    end

    # Additional penalty for soldiers with particularly low defensive stats
    defensive_power = @defense + @grit
    if defensive_power < 35  # Very low defense + grit
      weakness_penalty += 8
    elsif defensive_power < 45  # Low defense + grit
      weakness_penalty += 4
    end

    # Roll for attack success
    attack_roll = rand(attack_power)
    # Roll for survival/defense (reduced by weakness penalty)
    defense_roll = rand([survival_chance - weakness_penalty, 5].max)  # Minimum 5 to avoid impossible rolls

    # More punishing thresholds for weak soldiers
    adjusted_difficulty = difficulty + (weakness_penalty / 2)

    # More balanced combat thresholds
    case attack_roll
    when 0..(adjusted_difficulty - 20)
      # Poor attack - outcome depends on defense
      if defense_roll < (adjusted_difficulty - 15)
        @status = :kia
        false
      else
        @status = :injured
        improve_skills(difficulty / 3)
        false
      end
    when (adjusted_difficulty - 20)..(adjusted_difficulty - 10)
      # Decent attack
      if defense_roll < (adjusted_difficulty - 10)
        @status = :injured
        improve_skills(difficulty / 2)
        @success = true
      else
        @status = :shaken
        improve_skills(difficulty / 2)
        @success = true
      end
    when (adjusted_difficulty - 10)..(adjusted_difficulty)
      # Good attack
      if defense_roll < (adjusted_difficulty - 5)
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

  def is_weak_soldier?
    total_skill < 70 || (@defense + @grit) < 45
  end

  def weakness_level
    total = total_skill
    defensive = @defense + @grit

    if total < 60 || defensive < 35
      "Critical"
    elsif total < 70 || defensive < 45
      "High"
    elsif total < 80
      "Moderate"
    else
      "Low"
    end
  end

  def maybe_earn_nickname
    # Veterans with high skills should have nicknames
    # Define veteran status as total skill > 90 (was 100)
    if total_skill > 90 && !@name.include?('"')
      # 80% chance for veterans to earn nicknames (was 40%)
      if rand < 0.8
        @name = SoldierNameGenerator.generate_veteran_name(@name)
      end
    end

    # Elite veterans (total skill > 110) ALWAYS get nicknames
    if total_skill > 110 && !@name.include?('"')
      @name = SoldierNameGenerator.generate_veteran_name(@name)
    end
  end

  private

  def improve_skills(experience_gain)
    # Distribute experience across skills based on performance
    base_gain = [1, experience_gain / 4].max
    @offense += rand(1..base_gain)
    @defense += rand(1..base_gain)
    @grit += rand(1..base_gain)
    @leadership += rand(1..base_gain)

    # Check for nickname earning after improvement
    maybe_earn_nickname
  end
end
