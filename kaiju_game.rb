#!/usr/bin/env ruby

require_relative 'generators/battle_text'
require_relative 'models/squad'
require_relative 'models/kaiju'
require_relative 'models/location'
require_relative 'main_menu'
require_relative 'game_state'
require 'ostruct'

class KaijuGame
  STATUS_ICONS = {
    alive: "✅",
    injured: "🤕",
    shaken: "😰",
    kia: "💀"
  }.freeze

  def initialize
    @battle_text = BattleText.new
  end

  def show_game_specific_instructions
    puts "⭐ ENHANCED FEATURES:"
    puts "   • Detailed battle narratives with rich descriptions"
    puts "   • Individual soldier combat stories"
    puts "   • Immersive text and atmospheric presentation"
  end

  def show_game_specific_about
    puts "   • Enhanced storytelling with atmospheric descriptions"
    puts "   • Experience epic battles through rich narratives"
    puts
    puts "⭐ Features detailed battle descriptions and immersive storytelling!"
  end

  def play(game_state)
    clear_screen

    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   MISSION BRIEFING                     ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts

    # Show campaign status
    game_state.show_campaign_stats
    puts "\nPress Enter to continue to mission operations..."
    gets
    clear_screen

    # Main mission loop
    loop do
      # Check if there's a pending mission or generate new one
      unless game_state.has_pending_mission?
        kaiju = Kaiju.new
        location = Location.new
        game_state.set_pending_mission(kaiju, location)
      end

      # Show current mission
      mission_choice = show_mission_briefing(game_state.pending_mission)

      case mission_choice
      when :accept
        # Accept mission - proceed to squad selection
        clear_screen
        selected_squad = game_state.show_squad_selection_for_mission(game_state.pending_mission)

        if selected_squad
          # Conduct the mission
          result = conduct_accepted_mission(game_state.pending_mission, selected_squad, game_state)
          game_state.clear_pending_mission

          # Save after mission completion
          game_state.save_game

          # Ask if player wants to continue
          unless continue_operations?
            break
          end
        else
          # Player cancelled squad selection, keep the mission pending
          # Save game to preserve the mission
          game_state.save_game
        end

      when :reject
        # Reject mission - show destruction and generate new mission
        show_mission_rejection_consequences(game_state.pending_mission, game_state)
        game_state.clear_pending_mission
        game_state.save_game

      when :main_menu
        # Return to main menu - save current state including pending mission
        game_state.save_game
        puts "\n🏠 Returning to main menu..."
        puts "   Your current mission will be saved and available when you return."
        puts "Press Enter to continue..."
        gets
        break
      end
    end

    puts "\n🎌 Mission operations complete! Returning to main menu..."
    puts "Press Enter to continue..."
    gets
  end

  private

  def clear_screen
    begin
      system('clear') || system('cls')
    rescue
      # If screen clearing fails, just continue
      puts "\n" * 3  # Add some space instead
    end
  end

  def show_mission_briefing(pending_mission)
    clear_screen

    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    puts "🚨 KAIJU ALERT! 🚨"
    puts "=" * 60
    puts "📍 Target Location: #{location_data[:city]}"
    puts "🎯 Threat: \"#{kaiju_data[:name_english]}\" (#{kaiju_data[:name_monster]})"
    puts "📊 Classification: #{kaiju_data[:size].capitalize} #{kaiju_data[:creature]}"
    puts "🔍 Description: #{kaiju_data[:characteristic]}"
    puts "🛡️  Armor Type: #{kaiju_data[:material]} skinned"
    puts "⚔️  Primary Weapon: #{kaiju_data[:weapon]}"
    puts "⚠️  Threat Level: #{kaiju_data[:difficulty]}"
    puts "=" * 60
    puts
    puts "🤔 COMMAND DECISION REQUIRED"
    puts
    puts "What are your orders, Commander?"
    puts
    puts "1. ✅ Accept Mission - Deploy forces to engage"
    puts "2. ❌ Reject Mission - Stay at base (city will be attacked)"
    puts "3. 🏠 Return to Main Menu - Save and exit"
    print "Enter your choice (1-3): "

    choice = gets.chomp
    clear_screen

    case choice
    when "1"
      :accept
    when "2"
      :reject
    when "3"
      :main_menu
    else
      puts "❌ Invalid choice! Please try again."
      puts "Press Enter to continue..."
      gets
      show_mission_briefing(pending_mission)
    end
  end

  def show_mission_rejection_consequences(pending_mission, game_state)
    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    puts "💭 MISSION REJECTED"
    puts "=" * 60
    puts "You have chosen to keep your forces at base."
    puts "#{kaiju_data[:name_english]} continues its rampage unchallenged..."
    puts
    puts "⏰ 6 hours later..."
    puts

    # Generate destruction report
    destruction_lines = game_state.generate_destruction_description(kaiju_data, location_data)
    destruction_lines.each do |line|
      puts line
      sleep(0.8)
    end

    # Record the city destruction
    game_state.record_city_destruction

    puts
    puts "💔 The decision weighs heavily on your conscience."
    puts "   But your forces remain intact for the next threat."
    puts
    puts "Press Enter to await the next mission..."
    gets
    clear_screen
  end

  def conduct_accepted_mission(pending_mission, squad, game_state)
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

    # Handle recruitment for KIA replacements
    handle_recruitment(squad, game_state, casualties)

    # Return result
    { success: result, casualties: casualties }
  end

  def continue_operations?
    puts "\n" + "=" * 60
    puts "🎯 MISSION COMMAND"
    puts "=" * 60
    puts "Do you want to continue operations?"
    puts
    puts "1. ✅ Continue - Await next mission"
    puts "2. 🏠 Return to Base - End operations"
    print "Enter your choice (1 or 2): "

    choice = gets.chomp
    clear_screen
    choice == "1"
  end

  def count_casualties(squad)
    squad.soldiers.count { |s| s.status == :kia }
  end

  def handle_recruitment(squad, game_state, casualties)
    if casualties > 0
      clear_screen  # Clear screen for recruitment

      puts "\n" + "=" * 60
      puts "📋 RECRUITMENT PHASE"
      puts "=" * 60
      puts "💀 #{casualties} soldier(s) lost in action"
      puts "🔍 High Command is sending replacement personnel..."
      puts

      game_state.add_recruits_to_squad(squad, casualties)

      puts "\n📊 #{squad.name} now has #{squad.soldiers.count} active soldiers"
      puts "Press Enter to continue..."
      gets
      clear_screen  # Clear after input
    end
  end

  def show_threat(mission)
    kaiju, location = mission[:kaiju], mission[:location]

    puts "🚨 KAIJU ALERT! 🚨"
    puts "A terrifying kaiju has been spotted terrorizing #{location.city}!"
    puts
    puts "Target: \"#{kaiju.name_english}\" (#{kaiju.name_monster})"
    puts "Type: #{kaiju.size.capitalize} #{kaiju.creature}"
    puts "Description: #{kaiju.characteristic}"
    puts "Material: #{kaiju.material} skinned"
    puts "Primary Weapon: #{kaiju.weapon}"
    puts "Threat Level: #{kaiju.difficulty}"
    puts
  end

  def show_squad(squad, kaiju = nil)
    squad.show_squad_details(kaiju)
  end

  def show_rich_battle(squad, kaiju)
    system('clear') || system('cls')

    puts "⚔️  DETAILED BATTLE REPORT ⚔️"
    puts "\n\"#{kaiju.name_english}\" the #{kaiju.size} #{kaiju.creature} has made landfall!"
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

    success = squad.combat(kaiju.difficulty)

    # Show soldier results progressively
    squad.soldiers.each_with_index do |soldier, index|
      puts "🔄 Processing field report #{index + 1}/#{squad.soldiers.count}..."
      sleep(0.8)

      puts "📡 INCOMING TRANSMISSION..."
      sleep(0.5)

      puts "🪖 SOLDIER #{index + 1}: #{soldier.name.upcase}"
      puts "   Skills: #{soldier.skill_summary}"
      puts
      sleep(0.3)

      battle_texts = @battle_text.battle_summary(soldier)
      battle_texts.each do |text|
        puts "   #{text}"
        sleep(0.7)  # Pause between each line for dramatic effect
      end

      # Status reveal with pause
      sleep(0.5)
      if soldier.status != :alive
        puts "   #{STATUS_ICONS[soldier.status]} FINAL STATUS: #{soldier.status.to_s.upcase}"
        if soldier.status == :kia
          puts "   💔 Squad morale affected by loss..."
          sleep(1)
        end
      else
        puts "   #{STATUS_ICONS[soldier.status]} STATUS: #{soldier.status.to_s.upcase}"
      end

      puts
      puts "-" * 50

      # Pause between soldiers unless it's the last one
      if index < squad.soldiers.count - 1
        puts "⏳ Awaiting next field report..."
        sleep(1.2)
        puts
      end
    end

    # Dramatic pause before final results
    puts
    puts "📊 Compiling mission data..."
    sleep(1.5)
    puts "🎯 Analyzing battle outcome..."
    sleep(1)

    # Show enhanced mission outcome
    puts
    puts "=" * 60
    puts "📋 FINAL MISSION SUMMARY"
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
    puts "📡 Transmission complete. Press Enter to continue..."
    gets

    success
  end
end

# Run the game
if __FILE__ == $0
  game = KaijuGame.new
  game_state = GameState.new
  menu = MainMenu.new(game, game_state, "KAIJU DEFENSE FORCE", "Text Adventure")
  menu.run
end
