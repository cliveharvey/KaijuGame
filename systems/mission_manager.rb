#!/usr/bin/env ruby

require_relative '../models/kaiju'
require_relative '../models/location'
require_relative '../utils/arrow_menu'
require 'ostruct'

class MissionManager
  def initialize
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

  def generate_new_mission(game_state)
    # Generate balanced kaiju based on average of both squads
    squads = game_state.get_squads
    kaiju = Kaiju.new(squads)  # Balanced generation from start
    location = Location.new
    game_state.set_pending_mission(kaiju, location)
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
end
