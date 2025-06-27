require_relative '../generators/soldier_name_generator'

class Soldier
  attr_accessor :name, :offense, :defense, :grit, :leadership, :status, :success, :background,
                :level, :experience, :experience_to_next_level, :missions_completed, :successful_missions, :kills

  def initialize(name_length = nil, offense = rand(10..30), defense = rand(10..30), grit = rand(10..30), leadership = rand(10..30))
    @name = SoldierNameGenerator.generate_name
    @offense = offense
    @defense = defense
    @grit = grit
    @leadership = leadership
    @status = :alive
    @success = false
    @background = nil  # Will be set for recruits

    # Leveling system
    @level = 1
    @experience = 0
    @experience_to_next_level = experience_needed_for_level(2)
    @missions_completed = 0
    @successful_missions = 0
    @kills = 0
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
        gain_experience(difficulty / 3)
        false
      end
    when (adjusted_difficulty - 20)..(adjusted_difficulty - 10)
      if defense_roll < (adjusted_difficulty - 10)
        @status = :injured
        gain_experience(difficulty / 2)
        @success = true
      else
        @status = :shaken
        gain_experience(difficulty / 2)
        @success = true
      end
    when (adjusted_difficulty - 10)..(adjusted_difficulty)
      if defense_roll < (adjusted_difficulty - 5)
        @status = :shaken
        gain_experience(difficulty)
        @success = true
      else
        gain_experience(difficulty)
        @success = true
      end
    else
      gain_experience(difficulty + 5)
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

    # Balanced weakness penalties - weak soldiers face higher risk
    total_skill = @offense + @defense + @grit + @leadership
    weakness_penalty = 0

    if total_skill < 50
      weakness_penalty = 6  # Weak soldiers are at higher risk
    elsif total_skill < 60
      weakness_penalty = 4
    elsif total_skill < 70
      weakness_penalty = 2
    end

    defensive_power = @defense + @grit
    if defensive_power < 25
      weakness_penalty += 5  # Poor defensive stats are dangerous
    elsif defensive_power < 35
      weakness_penalty += 3
    elsif defensive_power < 45
      weakness_penalty += 1
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

    # Determine survival based on kaiju's attack vs soldier's defense (more realistic danger)
    kaiju_damage_roll = rand((kaiju_attack_power + special_penalty) / 2..(kaiju_attack_power + special_penalty + 10))
    survival_threshold = defense_roll + (@grit / 3) - weakness_penalty  # Weakness affects survival

            # Balanced thresholds based on kaiju difficulty
    danger_modifier = kaiju.difficulty / 20  # More gradual scaling
    chaos_factor = rand(-2..2)  # Less random chaos

    kia_threshold = survival_threshold + (15 - danger_modifier) + chaos_factor
    injured_threshold = survival_threshold + (10 - danger_modifier) + chaos_factor
    shaken_threshold = survival_threshold + (6 - danger_modifier) + chaos_factor

    if kaiju_damage_roll > kia_threshold
      @status = :kia
      @success = false  # Dead soldiers can't contribute
    elsif kaiju_damage_roll > injured_threshold
      @status = :injured
      gain_experience(experience_gain)
    elsif kaiju_damage_roll > shaken_threshold
      @status = :shaken
      gain_experience(experience_gain)
    else
      # Survived unharmed - bonus XP for clean performance
      gain_experience(experience_gain + 3)
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
    "Lv.#{@level} O:#{@offense} D:#{@defense} G:#{@grit} L:#{@leadership}"
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

  def complete_mission(mission_successful = false)
    @missions_completed += 1
    if mission_successful
      @successful_missions += 1
    end
    # Mission completion bonus
    gain_experience(10)
  end

  def record_kill
    @kills += 1
  end

  def gain_experience(exp_points)
    return [] if @status == :kia  # Dead soldiers don't gain experience

    old_level = @level
    @experience += exp_points.round

    # Check for level ups
    level_ups = []
    while @experience >= experience_needed_for_level(@level + 1)
      @level += 1
      level_up_stats = level_up!
      level_ups << level_up_stats
    end

    # Update experience to next level
    @experience_to_next_level = experience_needed_for_level(@level + 1) - @experience

    # Return level up information for display
    level_ups
  end

  def level_up!
    # Store old stats for comparison
    old_stats = {
      offense: @offense,
      defense: @defense,
      grit: @grit,
      leadership: @leadership
    }

    # Level up stat gains - more generous at higher levels
    base_gain = 1 + (@level / 5)  # Base gain increases every 5 levels

    # Random stat improvements
    offense_gain = rand(base_gain..(base_gain + 2))
    defense_gain = rand(base_gain..(base_gain + 2))
    grit_gain = rand(base_gain..(base_gain + 2))
    leadership_gain = rand(base_gain..(base_gain + 2))

    # Apply improvements
    @offense += offense_gain
    @defense += defense_gain
    @grit += grit_gain
    @leadership += leadership_gain

    # Check for nickname earning after leveling
    maybe_earn_nickname

    # Return stat changes for display
    {
      level: @level,
      old_stats: old_stats,
      new_stats: {
        offense: @offense,
        defense: @defense,
        grit: @grit,
        leadership: @leadership
      },
      gains: {
        offense: offense_gain,
        defense: defense_gain,
        grit: grit_gain,
        leadership: leadership_gain
      }
    }
  end

  def experience_needed_for_level(target_level)
    # Exponential XP curve: Level 2 = 50, Level 3 = 120, Level 4 = 220, etc.
    return 0 if target_level <= 1
    base = 50
    (base * (target_level - 1) * (target_level - 1) * 0.8).round
  end

  def experience_progress_bar
    return "MAX LEVEL" if @level >= 20  # Cap at level 20

    current = @experience
    needed = experience_needed_for_level(@level + 1)
    progress = (current.to_f / needed * 10).round

    bar = "█" * progress + "░" * (10 - progress)
    "#{bar} #{current}/#{needed} XP"
  end

  def level_title
    case @level
    when 1..2 then "Recruit"
    when 3..4 then "Private"
    when 5..6 then "Corporal"
    when 7..8 then "Sergeant"
    when 9..10 then "Staff Sergeant"
    when 11..12 then "Lieutenant"
    when 13..14 then "Captain"
    when 15..16 then "Major"
    when 17..18 then "Colonel"
    when 19..20 then "General"
    else "Legend"
    end
  end

  def detailed_info
    "#{@name} - #{level_title} (Level #{@level})\n" +
    "#{skill_summary} | Total: #{total_skill}\n" +
    "Experience: #{experience_progress_bar}\n" +
    "Missions: #{@missions_completed} | Status: #{@status.to_s.upcase}"
  end

  def maybe_earn_nickname
    # Veterans with high skills or levels should have nicknames
    if (@level >= 5 || total_skill > 90) && !@name.include?('"')
      # Higher chance for higher levels
      chance = [@level * 0.1, 0.8].min
      if rand < chance
        @name = SoldierNameGenerator.generate_veteran_name(@name)
      end
    end

    # Elite veterans ALWAYS get nicknames
    if (@level >= 10 || total_skill > 110) && !@name.include?('"')
      @name = SoldierNameGenerator.generate_veteran_name(@name)
    end
  end

  # Serialization for save/load
  def to_hash
    {
      name: @name,
      offense: @offense,
      defense: @defense,
      grit: @grit,
      leadership: @leadership,
      status: @status,
      background: @background,
      level: @level,
      experience: @experience,
      missions_completed: @missions_completed,
      successful_missions: @successful_missions,
      kills: @kills
    }
  end

  def self.from_hash(data)
    soldier = allocate
    soldier.instance_variable_set(:@name, data[:name])
    soldier.instance_variable_set(:@offense, data[:offense])
    soldier.instance_variable_set(:@defense, data[:defense])
    soldier.instance_variable_set(:@grit, data[:grit])
    soldier.instance_variable_set(:@leadership, data[:leadership])
    soldier.instance_variable_set(:@status, data[:status] || :alive)
    soldier.instance_variable_set(:@background, data[:background])
    soldier.instance_variable_set(:@level, data[:level] || 1)
    soldier.instance_variable_set(:@experience, data[:experience] || 0)
    soldier.instance_variable_set(:@missions_completed, data[:missions_completed] || 0)
    soldier.instance_variable_set(:@successful_missions, data[:successful_missions] || 0)
    soldier.instance_variable_set(:@kills, data[:kills] || 0)
    soldier.instance_variable_set(:@success, false)

    # Calculate experience to next level
    next_level_exp = soldier.experience_needed_for_level(soldier.level + 1)
    soldier.instance_variable_set(:@experience_to_next_level, next_level_exp - soldier.experience)

    soldier
  end

  private

  # Legacy method - now redirects to gain_experience
  def improve_skills(experience_gain)
    gain_experience(experience_gain)
  end
end
