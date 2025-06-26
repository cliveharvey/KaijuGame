require_relative 'soldier'

class Squad
  attr_reader :name
  attr_accessor :soldiers

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5)
    @name = name
    @soldiers = soldier_count.times.map { Soldier.new }
  end

  def combat(kaiju_or_difficulty)
    @soldiers.each { |soldier| soldier.combat(kaiju_or_difficulty) }
    @soldiers.count(&:success) >= 3
  end

  def show_squad_details(kaiju = nil)
    puts "\n📋 ASSEMBLING SQUAD: #{@name}"
    puts "Members:"
    @soldiers.each_with_index do |soldier, i|
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

        puts "  #{i + 1}. #{soldier.name} (#{soldier.skill_summary}) #{weakness_indicator}"
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

        puts "  #{i + 1}. #{soldier.name} (#{soldier.skill_summary}) #{weakness_indicator}"
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
