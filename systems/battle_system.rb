#!/usr/bin/env ruby

require_relative '../generators/battle_text'
require 'ostruct'

class BattleSystem
  STATUS_ICONS = {
    alive: "✅",
    injured: "🤕",
    shaken: "😰",
    kia: "💀"
  }.freeze

  def initialize
    @battle_text = BattleText.new
  end

  def conduct_battle(pending_mission, squad, game_state)
    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    puts "\n🎯 Deploying #{squad.name} to #{location_data[:city]}..."
    puts "Target: #{kaiju_data[:name_english]}"
    puts "Press Enter to begin the battle..."
    gets
    clear_screen

    # Create temporary kaiju object for battle (since we stored data as hash)
    temp_kaiju = OpenStruct.new(kaiju_data)
    result = show_rich_battle(squad, temp_kaiju)

    # Count casualties BEFORE removing them
    casualties = count_casualties(squad)

    # Reset soldier status for next mission (except for dead soldiers)
    squad.soldiers.each do |soldier|
      if soldier.status != :kia
        soldier.status = :alive
        soldier.success = false
      end
    end

    # Remove dead soldiers from the squad
    initial_count = squad.soldiers.count
    squad.soldiers.reject! { |soldier| soldier.status == :kia }
    removed_count = initial_count - squad.soldiers.count

    if removed_count > 0
      puts "\n💀 #{removed_count} soldier(s) will be remembered as heroes..."
      puts "   #{squad.name} continues with #{squad.soldiers.count} remaining members."
      puts "Press Enter to continue..."
      gets
      clear_screen
    end

    # Record mission results
    game_state.record_mission_result(result, result, casualties)

    # Return result
    { success: result, casualties: casualties }
  end

  def show_rich_battle(squad, kaiju)
    clear_screen

    puts "⚔️  DETAILED BATTLE REPORT ⚔️"
    puts "\n\"#{kaiju.name_english}\" the #{kaiju.size} #{kaiju.creature} has made landfall!"
    puts "🦖 The creature's #{kaiju.material} skin gleams in the light as it brandishes #{kaiju.weapon}!"
    puts "👁️  Notable feature: #{kaiju.characteristic}"
    puts

    # Show enhanced battle intro
    intro_texts = @battle_text.get_detailed_battle_intro(squad, kaiju)
    intro_texts.each { |text| puts text }
    puts
    puts "=" * 60
    puts "🎬 BATTLE COMMENCES..."
    puts "=" * 60
    puts

    puts "📡 Establishing communications with field units..."
    sleep(1.5)
    puts "🎯 Tactical data incoming..."
    sleep(1)
    puts "📊 Beginning real-time battle analysis..."
    sleep(1)
    puts

    success = squad.combat(kaiju)

    # Show a trait-based battle scene before individual reports
    puts "🌪️  KAIJU ENGAGEMENT INITIATED!"
    puts "   #{@battle_text.get_trait_based_combat_description(kaiju, success)}"
    puts
    sleep(2)

    # Show soldier battle results progressively (combat narrative only)
    squad.soldiers.each_with_index do |soldier, index|
      puts "🔄 Processing field report #{index + 1}/#{squad.soldiers.count}..."
      sleep(0.8)

      puts "📡 INCOMING TRANSMISSION..."
      sleep(0.5)

      puts "🪖 SOLDIER #{index + 1}: #{soldier.name.upcase}"
      puts "   Combat Skills: #{soldier.skill_summary}"
      puts
      sleep(0.3)

      battle_texts = @battle_text.battle_summary(soldier)
      battle_texts.each do |text|
        puts "   #{text}"
        sleep(0.7)  # Pause between each line for dramatic effect
      end

      # Add trait-specific interaction for this soldier
      if soldier.success || soldier.status != :kia
        trait_interaction = get_soldier_trait_interaction(soldier, kaiju)
        puts "   🎯 #{trait_interaction}"
        sleep(0.5)
      end

      puts "   📡 Transmission ended..."

      puts
      puts "-" * 50

      # Pause between soldiers unless it's the last one
      if index < squad.soldiers.count - 1
        puts "⏳ Awaiting next field report..."
        sleep(1.2)
        puts
      end
    end

    puts
    puts "📡 All combat transmissions complete."
    puts
    puts "Press Enter to view post-battle analysis..."
    gets

    clear_screen
    puts

    # Post-Battle Squad Analysis Phase
    puts "=" * 60
    puts "📊 POST-BATTLE SQUAD ANALYSIS"
    puts "=" * 60

    # Store level-up information for all soldiers
    all_level_ups = {}

    squad.soldiers.each_with_index do |soldier, index|
      puts "\n🪖 #{soldier.name}:"
      puts "   #{STATUS_ICONS[soldier.status]} Status: #{soldier.status.to_s.upcase}"

      if soldier.status == :kia
        puts "   💀 No experience gained"
        puts "   💔 Will be remembered as a hero..."
      else
        # Award experience and complete mission for survivors
        level_ups = soldier.complete_mission
        all_level_ups[soldier.name] = level_ups if level_ups.any?

        puts "   📈 Experience: #{soldier.experience_progress_bar}"

        if level_ups.any?
          puts "   🌟 PROMOTED! #{level_ups.map { |lu| "Level #{lu[:level]}" }.join(", ")}"
        end

        puts "   📊 Stats: #{soldier.skill_summary}"
      end
    end

    puts
    puts "Press Enter to continue to mission outcome..."
    gets

    # Show detailed level-up information
    if all_level_ups.any?
      show_promotion_ceremony(all_level_ups)
    end

    # Mission Outcome Phase
    show_mission_outcome(success, squad, all_level_ups)

    success
  end

  private

  def get_soldier_trait_interaction(soldier, kaiju)
    # Generate soldier-specific interactions with kaiju traits
    interactions = []

    # Based on soldier's dominant skill and kaiju traits
    dominant_skill = get_dominant_soldier_skill(soldier)

    case dominant_skill
    when :offense
      case kaiju.material
      when 'titanium', 'steel'
        interactions << "#{soldier.name} focused armor-piercing fire on the metallic plating"
      when 'glass'
        interactions << "#{soldier.name} targeted stress points in the crystalline armor"
      when 'ice'
        interactions << "#{soldier.name} used thermal ammunition against the frozen hide"
      else
        interactions << "#{soldier.name} found weak points in the #{kaiju.material} armor"
      end
    when :defense
      case kaiju.weapon
      when /claw/
        interactions << "#{soldier.name} used defensive positioning to avoid the creature's claws"
      when /breath|spit/
        interactions << "#{soldier.name} took cover from the creature's ranged attacks"
      when /roar|blast/
        interactions << "#{soldier.name} maintained composure despite the psychological assault"
      else
        interactions << "#{soldier.name} defensively countered the #{kaiju.weapon}"
      end
    when :grit
      interactions << "#{soldier.name} pushed through the terror of facing the #{kaiju.size} beast"
    when :leadership
      interactions << "#{soldier.name} coordinated the squad's response to the creature's #{kaiju.characteristic}"
    end

    interactions << "#{soldier.name} adapted their tactics to the creature's unique traits"
    interactions.sample
  end

  def get_dominant_soldier_skill(soldier)
    skills = {
      offense: soldier.offense,
      defense: soldier.defense,
      grit: soldier.grit,
      leadership: soldier.leadership
    }
    skills.max_by { |_, value| value }.first
  end

  def count_casualties(squad)
    squad.soldiers.count { |s| s.status == :kia }
  end

  def show_promotion_ceremony(all_level_ups)
    puts
    puts "🎖️  PROMOTION CEREMONY 🎖️"
    puts "=" * 60

    all_level_ups.each do |soldier_name, level_ups|
      level_ups.each do |level_up|
        puts "🌟 #{soldier_name} PROMOTED!"
        puts "   Level #{level_up[:level] - 1} → Level #{level_up[:level]} (#{get_level_title(level_up[:level])})"
        puts "   Stat Improvements:"
        puts "     • Offense: #{level_up[:old_stats][:offense]} → #{level_up[:new_stats][:offense]} (+#{level_up[:gains][:offense]})"
        puts "     • Defense: #{level_up[:old_stats][:defense]} → #{level_up[:new_stats][:defense]} (+#{level_up[:gains][:defense]})"
        puts "     • Grit: #{level_up[:old_stats][:grit]} → #{level_up[:new_stats][:grit]} (+#{level_up[:gains][:grit]})"
        puts "     • Leadership: #{level_up[:old_stats][:leadership]} → #{level_up[:new_stats][:leadership]} (+#{level_up[:gains][:leadership]})"
        puts
        sleep(1)
      end
    end

    puts "Press Enter to continue to mission results..."
    gets
    puts
  end

  def show_mission_outcome(success, squad, all_level_ups)
    puts "=" * 60
    puts "🎯 MISSION OUTCOME"
    puts "=" * 60

    if success
      puts "🎉 MISSION SUCCESSFUL!"
      sleep(0.5)
      puts "   The combined assault overwhelmed the kaiju!"
      sleep(0.5)
      puts "   #{squad.soldiers.count(&:success)} soldiers performed exceptionally!"
      sleep(0.5)

      # Show casualty breakdown
      alive_count = squad.soldiers.count { |s| s.status == :alive }
      shaken_count = squad.soldiers.count { |s| s.status == :shaken }
      injured_count = squad.soldiers.count { |s| s.status == :injured }
      kia_count = squad.soldiers.count { |s| s.status == :kia }

      puts "   Casualties: #{alive_count} unharmed, #{shaken_count} shaken, #{injured_count} injured, #{kia_count} KIA"
      sleep(0.5)

      if kia_count == 0
        puts "   🏆 FLAWLESS VICTORY - No lives lost!"
      elsif kia_count == 1
        puts "   ⚰️  One soldier made the ultimate sacrifice..."
      elsif kia_count > 1
        puts "   💀 Heavy casualties sustained in victory..."
      end

      # Show level-up summary
      if all_level_ups.any?
        total_promotions = all_level_ups.values.flatten.count
        puts "   🎖️  #{total_promotions} promotion(s) earned through combat experience!"
      end
    else
      puts "💥 MISSION FAILED"
      sleep(0.5)
      puts "   The kaiju proved too powerful for the squad..."
      sleep(0.5)
      puts "   Only #{squad.soldiers.count(&:success)} soldiers managed effective attacks."
      sleep(0.5)
      puts "   The monster continues its rampage across the city!"
    end

    puts
    puts "📡 Mission report complete. Press Enter to continue..."
    gets
  end

  def get_level_title(level)
    case level
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

  def clear_screen
    begin
      system('clear') || system('cls')
    rescue
      # If screen clearing fails, just continue
      puts "\n" * 3  # Add some space instead
    end
  end
end
