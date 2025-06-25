#!/usr/bin/env ruby

require_relative 'battle_text'
require_relative 'squad'
require_relative 'kaiju'
require_relative 'location'

class RichKaijuGame
  STATUS_ICONS = {
    alive: "✅",
    shaken: "⚡",
    injured: "🩹",
    kia: "💀"
  }.freeze

  def initialize
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   KAIJU DEFENSE FORCE                  ║"
    puts "║                  RICH TEXT ADVENTURE                    ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    @battle_text = BattleText.new
  end

  def play
    loop do
      mission = create_mission
      show_threat(mission)

      if deploy_decision?
        conduct_mission(mission)
      else
        puts "\n💥 You chose to stay at base. #{mission[:location].city} falls to the kaiju..."
      end

      break unless play_again?
    end

    puts "\n🎌 Thanks for playing Kaiju Defense Force!"
  end

  private

  def create_mission
    {
      kaiju: Kaiju.new,
      location: Location.new,
      squad: Squad.new
    }
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

  def conduct_mission(mission)
    kaiju, squad = mission[:kaiju], mission[:squad]

    show_squad(squad)

    puts "\nPress Enter to begin the battle..."
    gets

    show_rich_battle(squad, kaiju)
  end

  def show_squad(squad)
    puts "\n📋 ASSEMBLING SQUAD: #{squad.name}"
    puts "Members:"
    squad.soldiers.each_with_index do |soldier, i|
      puts "  #{i + 1}. #{soldier.name} (Skill: #{soldier.skill})"
    end
  end

  def show_rich_battle(squad, kaiju)
    system('clear') || system('cls')

    puts "⚔️  DETAILED BATTLE REPORT ⚔️"
    puts "\n\"#{kaiju.name_english}\" the #{kaiju.size} #{kaiju.creature} has made landfall!"
    puts

    success = squad.combat(kaiju.difficulty)

    # Show rich individual soldier narratives
    squad.soldiers.each do |soldier|
      puts "🪖 #{soldier.name.upcase} - COMBAT REPORT:"

      battle_texts = @battle_text.battle_summary(soldier)
      battle_texts.each { |text| puts "   #{text}" }

      if soldier.status != :alive
        puts "   #{STATUS_ICONS[soldier.status]} STATUS: #{soldier.status.to_s.upcase}"
      end
      puts
    end

    # Show mission outcome
    puts "-" * 60
    if success
      puts "🎉 MISSION SUCCESSFUL!"
      puts "The combined assault overwhelmed the kaiju!"
      puts "#{squad.soldiers.count(&:success)} soldiers performed exceptionally!"
    else
      puts "💥 MISSION FAILED"
      puts "The kaiju proved too powerful for the squad..."
      puts "Only #{squad.soldiers.count(&:success)} soldiers managed effective attacks."
    end

    puts "\nPress Enter to continue..."
    gets
  end

  def play_again?
    puts "\n" + "=" * 60
    print "Play another mission? (y/n): "
    input = gets
    return false if input.nil?
    input.chomp.downcase.start_with?('y')
  end
end

# Run the rich game
if __FILE__ == $0
  game = RichKaijuGame.new
  game.play
end
