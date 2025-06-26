require_relative '../generators/soldier_name_generator'

class Soldier
  attr_accessor :name, :offense, :defense, :grit, :leadership, :status, :success, :background

  def initialize(name_length = nil, offense = rand(10..30), defense = rand(10..30), grit = rand(10..30), leadership = rand(10..30))
    @name = SoldierNameGenerator.generate_name
    @offense = offense
    @defense = defense
    @grit = grit
    @leadership = leadership
    @status = :alive
    @success = false
    @background = nil  # Will be set for recruits
  end

  def combat(kaiju_or_difficulty)
    # Handle both old difficulty system and new kaiju system
    if kaiju_or_difficulty.is_a?(Numeric)
      # Legacy support - just use old system
      return combat_legacy(kaiju_or_difficulty)
    end

    # New kaiju-based combat system
    kaiju = kaiju_or_difficulty
    combat_vs_kaiju(kaiju)
  end

  def combat_legacy(difficulty)
    # Original combat system for backward compatibility
    attack_power = @offense + (@leadership / 2)
    survival_chance = @defense + (@grit / 2)

    total_skill = @offense + @defense + @grit + @leadership
    weakness_penalty = 0

    if total_skill < 60
      weakness_penalty = 10
    elsif total_skill < 70
      weakness_penalty = 5
    end

    defensive_power = @defense + @grit
    if defensive_power < 35
      weakness_penalty += 8
    elsif defensive_power < 45
      weakness_penalty += 4
    end

    attack_roll = rand(attack_power)
    defense_roll = rand([survival_chance - weakness_penalty, 5].max)
    adjusted_difficulty = difficulty + (weakness_penalty / 2)

    case attack_roll
    when 0..(adjusted_difficulty - 20)
      if defense_roll < (adjusted_difficulty - 15)
        @status = :kia
        false
      else
        @status = :injured
        improve_skills(difficulty / 3)
        false
      end
    when (adjusted_difficulty - 20)..(adjusted_difficulty - 10)
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
      if defense_roll < (adjusted_difficulty - 5)
        @status = :shaken
        improve_skills(difficulty)
        @success = true
      else
        improve_skills(difficulty)
        @success = true
      end
    else
      improve_skills(difficulty + 5)
      @success = true
    end
  end

  def combat_vs_kaiju(kaiju)
    # Enhanced combat system using kaiju stats
    soldier_attack = @offense + (@leadership / 2)
    soldier_defense = @defense + (@grit / 2)

    # Kaiju stats affect combat
    kaiju_attack_power = kaiju.offense
    kaiju_defense_power = kaiju.defense
    kaiju_speed = kaiju.speed
    kaiju_special = kaiju.special

    # Speed affects initiative and dodge chance
    speed_difference = kaiju_speed - speed_equivalent
    dodge_penalty = [speed_difference / 3, 0].max  # Faster kaiju are harder to hit

    # Special abilities create additional challenges
    special_penalty = kaiju_special / 4

    # Much more forgiving weakness penalties
    total_skill = @offense + @defense + @grit + @leadership
    weakness_penalty = 0

    if total_skill < 50
      weakness_penalty = 6
    elsif total_skill < 60
      weakness_penalty = 3
    end

    defensive_power = @defense + @grit
    if defensive_power < 25
      weakness_penalty += 4
    elsif defensive_power < 35
      weakness_penalty += 2
    end

    # Combat rolls with kaiju stats
    attack_roll = rand(soldier_attack/2..soldier_attack)
    defense_roll = rand((soldier_defense - weakness_penalty)/2..soldier_defense)

    # Kaiju's defense makes it harder to damage
    effective_kaiju_defense = kaiju_defense_power + dodge_penalty + special_penalty

    # Determine attack effectiveness
    attack_success_threshold = effective_kaiju_defense / 2
    if attack_roll > attack_success_threshold
      @success = true
      experience_gain = kaiju.difficulty / 2
    else
      @success = false
      experience_gain = kaiju.difficulty / 4
    end

    # Determine survival based on kaiju's attack vs soldier's defense (much more forgiving)
    kaiju_damage_roll = rand(kaiju_attack_power + special_penalty)
    survival_threshold = defense_roll + (@grit / 2)  # Grit helps more with survival

    if kaiju_damage_roll > survival_threshold + 25
      @status = :kia
      @success = false  # Dead soldiers can't contribute
    elsif kaiju_damage_roll > survival_threshold + 15
      @status = :injured
      improve_skills(experience_gain)
    elsif kaiju_damage_roll > survival_threshold + 8
      @status = :shaken
      improve_skills(experience_gain)
    else
      # Survived unharmed
      improve_skills(experience_gain)
    end

    @success
  end

  def speed_equivalent
    # Convert soldier skills to speed equivalent
    (@offense + @grit) / 3  # Offense and grit contribute to combat speed
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
