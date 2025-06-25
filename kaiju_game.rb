#!/usr/bin/env ruby

require_relative 'generators/battle_text'
require_relative 'models/squad'
require_relative 'models/kaiju'
require_relative 'models/location'
require_relative 'main_menu'
require_relative 'game_state'

class KaijuGame
  STATUS_ICONS = {
    alive: "✅",
    shaken: "⚡",
    injured: "🩹",
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
    system('clear') || system('cls')
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   MISSION BRIEFING                     ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts

    # Show campaign status
    game_state.show_campaign_stats
    puts "\nPress Enter to continue to mission selection..."
    gets

    loop do
      mission = create_mission(game_state)
      break unless mission # Player cancelled

      show_threat(mission)

      if deploy_decision?
        result = conduct_mission(mission, game_state)

        # Record mission results
        casualties = result[:casualties]
        game_state.record_mission_result(result[:success], result[:success], casualties)

        # Handle recruitment for KIA replacements
        handle_recruitment(mission[:squad], game_state, casualties)

        # Save game after each mission
        game_state.save_game
      else
        puts "\n💥 You chose to stay at base. #{mission[:location].city} falls to the kaiju..."
        game_state.record_mission_result(false, false, 0)
        game_state.save_game
      end

      break unless play_again?
    end

    puts "\n🎌 Mission series complete! Returning to main menu..."
    puts "Press Enter to continue..."
    gets
  end

  private

  def create_mission(game_state)
    kaiju = Kaiju.new
    location = Location.new

    # Let player choose which squad to deploy
    selected_squad = game_state.show_squad_selection(kaiju)

    return nil unless selected_squad # Player cancelled

    {
      kaiju: kaiju,
      location: location,
      squad: selected_squad
    }
  end

  def count_casualties(squad)
    squad.soldiers.count { |s| s.status == :kia }
  end

  def handle_recruitment(squad, game_state, casualties)
    if casualties > 0
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

  def deploy_decision?
    puts "What is your decision, Commander?"
    puts "1. Deploy troops to engage the kaiju"
    puts "2. Stay at base (let the city fall)"
    print "Enter your choice (1 or 2): "

    gets.chomp == "1"
  end

  def conduct_mission(mission, game_state)
    kaiju, squad = mission[:kaiju], mission[:squad]

    puts "\n🎯 Deploying #{squad.name}..."
    puts "Press Enter to begin the battle..."
    gets

    result = show_rich_battle(squad, kaiju)

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
    end

    # Return both result and casualties
    { success: result, casualties: casualties }
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

  def play_again?
    puts "\n" + "=" * 60
    print "Continue to next mission? (y/n): "
    input = gets
    return false if input.nil?
    input.chomp.downcase.start_with?('y')
  end
end

# Run the game
if __FILE__ == $0
  game = KaijuGame.new
  game_state = GameState.new
  menu = MainMenu.new(game, game_state, "KAIJU DEFENSE FORCE", "Text Adventure")
  menu.run
end
