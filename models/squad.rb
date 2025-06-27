require_relative 'soldier'

class Squad
  attr_reader :name
  attr_accessor :soldiers, :missions_completed, :victories, :toughest_kaiju_defeated, :total_casualties

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5)
    @name = name
    @soldiers = soldier_count.times.map { Soldier.new }
    @missions_completed = 0
    @victories = 0
    @toughest_kaiju_defeated = nil
    @total_casualties = 0
  end

  def leader
    # Find soldier with highest leadership (ties go to first found)
    @soldiers.max_by(&:leadership)
  end

  def apply_leadership_bonuses
    squad_leader = leader
    return unless squad_leader

    # Leadership bonus: 10% of leader's leadership to other squad members
    leadership_bonus = (squad_leader.leadership * 0.1).round

    @soldiers.each do |soldier|
      next if soldier == squad_leader  # Leader doesn't boost themselves

      # Apply temporary bonuses (store original values if not already stored)
      soldier.instance_variable_set(:@original_offense, soldier.offense) unless soldier.instance_variable_get(:@original_offense)
      soldier.instance_variable_set(:@original_defense, soldier.defense) unless soldier.instance_variable_get(:@original_defense)
      soldier.instance_variable_set(:@original_grit, soldier.grit) unless soldier.instance_variable_get(:@original_grit)

      # Apply leadership bonuses
      soldier.offense = soldier.instance_variable_get(:@original_offense) + leadership_bonus
      soldier.defense = soldier.instance_variable_get(:@original_defense) + leadership_bonus
      soldier.grit = soldier.instance_variable_get(:@original_grit) + (leadership_bonus / 2).round
    end
  end

  def remove_leadership_bonuses
    # Restore original stats
    @soldiers.each do |soldier|
      if soldier.instance_variable_get(:@original_offense)
        soldier.offense = soldier.instance_variable_get(:@original_offense)
        soldier.defense = soldier.instance_variable_get(:@original_defense)
        soldier.grit = soldier.instance_variable_get(:@original_grit)

        # Clear the stored values
        soldier.remove_instance_variable(:@original_offense)
        soldier.remove_instance_variable(:@original_defense)
        soldier.remove_instance_variable(:@original_grit)
      end
    end
  end

  def combat(kaiju_or_difficulty)
    # Apply leadership bonuses before combat
    apply_leadership_bonuses

    # Run combat
    @soldiers.each { |soldier| soldier.combat(kaiju_or_difficulty) }
    success = @soldiers.count(&:success) >= 3

    # Remove bonuses after combat to restore original stats
    remove_leadership_bonuses

    success
  end

  def show_squad_details(kaiju = nil)
    squad_leader = leader

    puts "\n📋 ASSEMBLING SQUAD: #{@name}"
    puts "👑 Squad Leader: #{squad_leader.name} (Leadership: #{squad_leader.leadership})"

    if squad_leader.leadership >= 20
      leadership_bonus = (squad_leader.leadership * 0.1).round
      puts "   ✨ Leadership Bonus: +#{leadership_bonus} ATK/DEF, +#{(leadership_bonus/2).round} GRT to squad members"
    end

    puts "Members:"
    @soldiers.each_with_index do |soldier, i|
      leader_indicator = soldier == squad_leader ? "👑 " : "   "

      if kaiju
        risk_level = calculate_kaiju_risk(soldier, kaiju)
        weakness_indicator = case risk_level
        when "Critical"
          "🔴"
        when "High"
          "🟠"
        when "Moderate"
          "🟡"
        else
          "🟢"
        end

        puts "#{leader_indicator}#{i + 1}. #{soldier.name} (#{soldier.skill_summary}) #{weakness_indicator}"
      else
        # Fallback to general weakness if no kaiju provided
        weakness_indicator = case soldier.weakness_level
        when "Critical"
          "🔴"
        when "High"
          "🟠"
        when "Moderate"
          "🟡"
        else
          "🟢"
        end

        puts "#{leader_indicator}#{i + 1}. #{soldier.name} (#{soldier.skill_summary}) #{weakness_indicator}"
      end
    end
    puts

    if kaiju
      puts "Risk vs #{kaiju.size.capitalize} #{kaiju.creature} (Threat #{kaiju.difficulty}): 🟢 Low | 🟡 Moderate | 🟠 High | 🔴 Critical"

      # Show squad analysis
      critical_count = @soldiers.count { |s| calculate_kaiju_risk(s, kaiju) == "Critical" }
      high_count = @soldiers.count { |s| calculate_kaiju_risk(s, kaiju) == "High" }

      if critical_count > 0
        puts "⚠️  #{critical_count} soldier(s) at critical risk against this kaiju"
      end
      if high_count > 0
        puts "🚨 #{high_count} soldier(s) at high risk against this kaiju"
      end

      # Mission probability assessment - more realistic calculation
      assessment = calculate_realistic_mission_assessment(kaiju)

      case assessment[:level]
      when :favorable
        puts "📊 Mission Assessment: FAVORABLE - Low casualty risk expected"
      when :balanced
        puts "📊 Mission Assessment: BALANCED - Moderate casualties likely"
      when :challenging
        puts "📊 Mission Assessment: CHALLENGING - High casualty risk"
      when :desperate
        puts "📊 Mission Assessment: DESPERATE - Extreme danger to all soldiers"
      when :suicide
        puts "📊 Mission Assessment: SUICIDE MISSION - Squad likely to be wiped out"
      end

      puts "   Expected Casualties: #{assessment[:casualties]}"
      puts "   Mission Success Probability: #{assessment[:success_chance]}%"
    else
      puts "General Risk Legend: 🟢 Low Risk | 🟡 Moderate Risk | 🟠 High Risk | 🔴 Critical Risk"
    end
  end

  def record_mission_result(success, kaiju_data, casualties)
    @missions_completed += 1
    @victories += 1 if success
    @total_casualties += casualties

    # Track toughest kaiju defeated (only if successful)
    if success && kaiju_data
      if @toughest_kaiju_defeated.nil? || kaiju_data[:difficulty] > @toughest_kaiju_defeated[:difficulty]
        @toughest_kaiju_defeated = {
          name: kaiju_data[:name_english],
          designation: kaiju_data[:name_monster],
          difficulty: kaiju_data[:difficulty],
          size: kaiju_data[:size],
          creature: kaiju_data[:creature],
          location: kaiju_data[:location]
        }
      end
    end
  end

  def squad_statistics
    return {} if @missions_completed == 0

    {
      missions_completed: @missions_completed,
      victories: @victories,
      success_rate: ((@victories.to_f / @missions_completed) * 100).round(1),
      total_casualties: @total_casualties,
      avg_casualties_per_mission: (@total_casualties.to_f / @missions_completed).round(1),
      toughest_kaiju: @toughest_kaiju_defeated,
      veteran_count: @soldiers.count { |s| s.level >= 3 },
      elite_count: @soldiers.count { |s| s.level >= 5 }
    }
  end

  private

  def calculate_realistic_mission_assessment(kaiju)
    # Much more forgiving assessment for balanced kaiju
    avg_soldier_power = @soldiers.sum(&:total_skill) / @soldiers.count.to_f
    threat_ratio = kaiju.difficulty.to_f / avg_soldier_power

    # Estimate success chance based on threat ratio
    if threat_ratio < 0.3
      success_percentage = 85 + rand(10)  # 85-95%
      avg_casualties = 0.0 + rand(0.2)   # 0-0.2
    elsif threat_ratio < 0.5
      success_percentage = 70 + rand(15)  # 70-85%
      avg_casualties = 0.1 + rand(0.3)   # 0.1-0.4
    elsif threat_ratio < 0.7
      success_percentage = 55 + rand(15)  # 55-70%
      avg_casualties = 0.3 + rand(0.5)   # 0.3-0.8
    elsif threat_ratio < 1.0
      success_percentage = 40 + rand(15)  # 40-55%
      avg_casualties = 0.5 + rand(0.8)   # 0.5-1.3
    else
      success_percentage = 20 + rand(20)  # 20-40%
      avg_casualties = 1.0 + rand(1.5)   # 1.0-2.5
    end

    # Determine assessment level based on more reasonable thresholds
    if avg_casualties >= 2.0
      level = :suicide
    elsif avg_casualties >= 1.5
      level = :desperate
    elsif avg_casualties >= 1.0
      level = :challenging
    elsif avg_casualties >= 0.5
      level = :balanced
    else
      level = :favorable
    end

    # Adjust based on success rate
    if success_percentage < 30
      level = :suicide
    elsif success_percentage < 50 && level != :suicide
      level = :desperate
    elsif success_percentage < 70 && level == :favorable
      level = :balanced
    end

    {
      level: level,
      casualties: "#{avg_casualties.round(1)}/#{@soldiers.count}",
      success_chance: success_percentage.round
    }
  end

  def calculate_kaiju_risk(soldier, kaiju)
    # Much more forgiving risk calculation for balanced kaiju
    soldier_power = soldier.total_skill
    threat_ratio = kaiju.difficulty.to_f / soldier_power

    # More reasonable risk thresholds
    if threat_ratio > 0.8
      "Critical"
    elsif threat_ratio > 0.6
      "High"
    elsif threat_ratio > 0.4
      "Moderate"
    else
      "Low"
    end
  end
end
