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
    # Simulate combat for each soldier to get realistic expectations
    total_simulations = 100
    total_casualties = 0
    total_successes = 0

    total_simulations.times do
      casualties_this_sim = 0
      successes_this_sim = 0

      @soldiers.each do |soldier|
        # Simulate the actual combat logic from soldier.rb
        attack_power = soldier.offense + (soldier.leadership / 2)
        survival_chance = soldier.defense + (soldier.grit / 2)

        # Apply weakness penalties (same as actual combat)
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

        # Simulate combat rolls
        attack_roll = rand(attack_power)
        defense_roll = rand([survival_chance - weakness_penalty, 5].max)
        adjusted_difficulty = kaiju.difficulty + (weakness_penalty / 2)

        # Determine outcome using same thresholds as actual combat
        if attack_roll <= (adjusted_difficulty - 20)
          # Poor attack
          if defense_roll < (adjusted_difficulty - 15)
            casualties_this_sim += 1  # KIA
          end
          # Injured soldiers don't count as success
        elsif attack_roll <= (adjusted_difficulty - 10)
          # Decent attack
          successes_this_sim += 1
          if defense_roll < (adjusted_difficulty - 10)
            casualties_this_sim += 1  # Injured but success
          end
        elsif attack_roll <= adjusted_difficulty
          # Good attack
          successes_this_sim += 1
        else
          # Excellent attack
          successes_this_sim += 1
        end
      end

      total_casualties += casualties_this_sim
      total_successes += (successes_this_sim >= 3 ? 1 : 0)  # Mission success needs 3+ successes
    end

    avg_casualties = (total_casualties.to_f / total_simulations).round(1)
    success_percentage = (total_successes * 100 / total_simulations)

    # Determine assessment level based on realistic simulation
    if avg_casualties >= 4.0
      level = :suicide
    elsif avg_casualties >= 3.0
      level = :desperate
    elsif avg_casualties >= 2.0
      level = :challenging
    elsif avg_casualties >= 1.0
      level = :balanced
    else
      level = :favorable
    end

    # Override to more severe if success rate is very low
    if success_percentage < 20
      level = :suicide
    elsif success_percentage < 40
      level = :desperate
    elsif success_percentage < 60 && level == :favorable
      level = :balanced
    end

    {
      level: level,
      casualties: "#{avg_casualties}/#{@soldiers.count}",
      success_chance: success_percentage
    }
  end

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
