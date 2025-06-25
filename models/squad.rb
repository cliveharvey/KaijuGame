require_relative 'soldier'

class Squad
  attr_reader :name
  attr_accessor :soldiers

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5)
    @name = name
    @soldiers = soldier_count.times.map { Soldier.new }
  end

  def combat(difficulty)
    @soldiers.each { |soldier| soldier.combat(difficulty) }
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

      # Mission probability assessment
      total_power = @soldiers.sum { |s| s.total_skill }
      avg_power = total_power / @soldiers.count
      threat_ratio = kaiju.difficulty.to_f / avg_power

      if threat_ratio < 0.8
        puts "📊 Mission Assessment: FAVORABLE - Squad well-equipped for this threat"
      elsif threat_ratio < 1.2
        puts "📊 Mission Assessment: BALANCED - Expect moderate casualties"
      elsif threat_ratio < 1.8
        puts "📊 Mission Assessment: CHALLENGING - High casualty risk"
      else
        puts "📊 Mission Assessment: DESPERATE - Extreme danger to all soldiers"
      end
    else
      puts "General Risk Legend: 🟢 Low Risk | 🟡 Moderate Risk | 🟠 High Risk | 🔴 Critical Risk"
    end
  end

  private

  def calculate_kaiju_risk(soldier, kaiju)
    # Calculate soldier's effective power
    attack_power = soldier.offense + (soldier.leadership / 2)
    survival_power = soldier.defense + (soldier.grit / 2)

    # Apply weakness penalties (same as combat system)
    total_skill = soldier.total_skill
    weakness_penalty = 0

    if total_skill < 60
      weakness_penalty = 10
    elsif total_skill < 70
      weakness_penalty = 5
    end

    defensive_power = soldier.defense + soldier.grit
    if defensive_power < 35
      weakness_penalty += 8
    elsif defensive_power < 45
      weakness_penalty += 4
    end

    adjusted_survival = [survival_power - weakness_penalty, 5].max
    adjusted_difficulty = kaiju.difficulty + (weakness_penalty / 2)

    # Calculate survival probability for poor attacks (most dangerous scenario)
    survival_threshold = adjusted_difficulty - 15
    survival_probability = (adjusted_survival - survival_threshold).to_f / adjusted_survival

    # Determine risk level based on survival probability
    if survival_probability < 0.3
      "Critical"
    elsif survival_probability < 0.5
      "High"
    elsif survival_probability < 0.7
      "Moderate"
    else
      "Low"
    end
  end
end
