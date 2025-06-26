#!/usr/bin/env ruby

require_relative 'generators/battle_text'
require_relative 'models/squad'
require_relative 'models/kaiju'
require_relative 'models/location'
require_relative 'main_menu'
require_relative 'game_state'
require_relative 'utils/arrow_menu'
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
    puts "   • Dual squad management with unique generated names"
    puts "   • 4-skill soldier system (Offense, Defense, Grit, Leadership)"
    puts "   • Dynamic risk assessment against specific kaiju threats"
    puts "   • Veterans earn nicknames and callsigns automatically"
    puts "   • Mission persistence - save and resume anytime"
    puts "   • City destruction consequences for rejected missions"
  end

  def show_game_specific_about
    puts "   • Enhanced storytelling with atmospheric descriptions"
    puts "   • Sophisticated kaiju and soldier name generation"
    puts "   • Progressive battle reporting with dramatic timing"
    puts "   • Arrow key navigation for classic console feel"
    puts "   • Comprehensive campaign tracking and statistics"
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
        # Generate balanced kaiju based on average of both squads
        squads = game_state.get_squads
        kaiju = Kaiju.new(squads)  # Balanced generation from start
        location = Location.new
        game_state.set_pending_mission(kaiju, location)
      end

      # Show current mission using arrow menu
      mission_choice = show_mission_briefing_with_menu(game_state.pending_mission)

      case mission_choice
      when 1 # Accept
        # Accept mission - proceed to squad selection
        clear_screen
        selected_squad = show_squad_selection_with_menu(game_state.pending_mission, game_state)

                if selected_squad
          # Conduct the mission with already balanced kaiju
          result = conduct_accepted_mission(game_state.pending_mission, selected_squad, game_state)
          game_state.clear_pending_mission

          # Save after mission completion
          game_state.save_game

          # Ask if player wants to continue
          unless continue_operations_with_menu?
            break
          end
        else
          # Player cancelled squad selection, keep the mission pending
          # Save game to preserve the mission
          game_state.save_game
        end

      when 2 # Reject
        # Reject mission - show destruction and generate new mission
        show_mission_rejection_consequences(game_state.pending_mission, game_state)
        game_state.clear_pending_mission
        game_state.save_game

      when 3 # Main menu
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

  def show_mission_briefing_with_menu(pending_mission)
    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    # Show detailed kaiju info first
    clear_screen
    puts "🚨 KAIJU ALERT! 🚨"
    puts "=" * 60
    puts "📍 Target Location: #{location_data[:city]}"
    puts "🎯 Threat: \"#{kaiju_data[:name_english]}\" (#{kaiju_data[:name_monster]})"
    puts "📊 Classification: #{kaiju_data[:size].capitalize} #{kaiju_data[:creature]}"
    puts "🔍 Description: #{kaiju_data[:characteristic]}"
    puts "🛡️  Armor Type: #{kaiju_data[:material]} skinned"
    puts "⚔️  Primary Weapon: #{kaiju_data[:weapon]}"
    puts "⚠️  Threat Level: #{kaiju_data[:difficulty]}"
    puts "📈 Combat Stats: ATK:#{kaiju_data[:offense]} DEF:#{kaiju_data[:defense]} SPD:#{kaiju_data[:speed]} SPC:#{kaiju_data[:special]}"
    puts "=" * 60
    puts

    # Use arrow menu for choices
    menu = MissionMenu.new(kaiju_data[:name_english], location_data[:city], kaiju_data[:difficulty])
    menu.show
  end

  def show_squad_selection_with_menu(pending_mission, game_state)
    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    # Create temporary kaiju object for risk assessment
    temp_kaiju = OpenStruct.new(kaiju_data)

    # Show detailed squad information with risk assessment first
    clear_screen
    puts "\n" + "=" * 60
    puts "📋 SQUAD DEPLOYMENT ANALYSIS"
    puts "=" * 60
    puts "🎯 Mission: Engage #{kaiju_data[:name_english]} at #{location_data[:city]}"
    puts "⚠️  Threat Level: #{kaiju_data[:difficulty]} | Type: #{kaiju_data[:size].capitalize} #{kaiju_data[:creature]}"
    puts

    squads = game_state.get_squads
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. #{squad.name.upcase}"
      squad.show_squad_details(temp_kaiju)
      puts
    end

    puts "Press Enter to continue to deployment selection..."
    gets

    # Now show the menu for selection
    menu = SquadMenu.new(squads, kaiju_data[:name_english], location_data[:city])
    choice = menu.show

    if choice && choice <= squads.length
      squads[choice - 1]
    else
      nil # Cancelled
    end
  end

  def continue_operations_with_menu?
    options = [
      "✅ Continue - Await next mission",
      "🏠 Return to Base - End operations"
    ]

    menu = ArrowMenu.new(options, "🎯 MISSION COMMAND", "Do you want to continue operations?")
    choice = menu.show

    choice == 1
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
  menu = MainMenu.new
  menu.run
end
