#!/usr/bin/env ruby

require_relative 'kaiju_game'
require_relative 'game_state'
require_relative 'utils/arrow_menu'

class MainMenu
  def initialize(title = "KAIJU DEFENSE FORCE", subtitle = "Text Adventure")
    @title = title
    @subtitle = subtitle
    @game_state = GameState.new
  end

  def run
    show_intro

    loop do
      choice = show_main_menu

      case choice
      when 1
        handle_continue_campaign
      when 2
        handle_new_campaign
      when 3
        handle_squad_management
      when 4
        handle_campaign_statistics
      when 5
        handle_how_to_play
      when 6
        handle_about_game
      when 7
        handle_quit_game
        break
      when nil
        handle_quit_game
        break
      end
    end
  end

  private

  def show_intro
    system('clear') || system('cls')
    puts
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                    #{@title}                    ║"
    puts "║                       #{@subtitle}                           ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎌 Welcome, Commander! The world needs your leadership!"
    puts
    puts "Press Enter to continue..."
    gets
  end

  def show_main_menu
    options = []

    if @game_state.save_exists?
      options << "🔄 Continue Campaign"
    end

    options.concat([
      "🆕 New Campaign",
      "🪖 Squad Management",
      "📊 Campaign Statistics",
      "📖 How to Play",
      "🌟 About the Game",
      "🚪 Quit Game"
    ])

    menu = ArrowMenu.new(options, "🎌 KAIJU DEFENSE FORCE MAIN MENU", "Choose your action, Commander:")
    choice = menu.show

    # Adjust choice based on whether continue option is present
    if @game_state.save_exists?
      choice
    else
      choice ? choice + 1 : nil  # Shift choices by 1 if no continue option
    end
  end

  def handle_continue_campaign
    if @game_state.load_game
      game = KaijuGame.new
      game.play(@game_state)
    else
      puts "❌ No saved campaign found!"
      puts "Press Enter to continue..."
      gets
    end
  end

  def handle_new_campaign
    if @game_state.save_exists?
      system('clear') || system('cls')
      puts "⚠️  EXISTING CAMPAIGN DETECTED"
      puts "=" * 50
      puts "You already have a saved campaign."
      puts "Starting a new campaign will delete your existing progress."
      puts

      confirm_options = [
        "✅ Yes, start new campaign (delete existing save)",
        "❌ No, return to main menu"
      ]

      confirm_menu = ArrowMenu.new(confirm_options, "⚠️ CONFIRM NEW CAMPAIGN", "Are you sure you want to delete your existing campaign?")
      choice = confirm_menu.show

      if choice == 1
        @game_state.delete_save
        start_new_campaign
      end
    else
      start_new_campaign
    end
  end

  def start_new_campaign
    @game_state = GameState.new
    @game_state.create_new_squads
    @game_state.save_game

    game = KaijuGame.new
    game.play(@game_state)
  end

  def handle_squad_management
    system('clear') || system('cls')

    if @game_state.save_exists?
      @game_state.load_game
      show_squad_management_menu
    else
      puts "🪖 SQUAD MANAGEMENT"
      puts "=" * 30
      puts "No campaign data found."
      puts "Start a new campaign to create squads!"
      puts "\nPress Enter to return to main menu..."
      gets
    end
  end

  def handle_campaign_statistics
    system('clear') || system('cls')

    if @game_state.save_exists?
      @game_state.load_game
      @game_state.show_campaign_stats
    else
      puts "📊 CAMPAIGN STATISTICS"
      puts "=" * 30
      puts "No campaign data found."
      puts "Start a new campaign to begin tracking statistics!"
    end

    puts "\nPress Enter to return to main menu..."
    gets
  end

  def show_squad_management_menu
    loop do
      system('clear') || system('cls')

      puts "╔════════════════════════════════════════════════════════╗"
      puts "║                   SQUAD MANAGEMENT                    ║"
      puts "╚════════════════════════════════════════════════════════╝"
      puts

      squads = @game_state.get_squads
      options = []

      squads.each do |squad|
        options << "📋 View #{squad.name} Details"
      end

      options << "🏠 Return to Main Menu"

      menu = ArrowMenu.new(options, "🪖 SQUAD COMMAND CENTER", "Choose a squad to inspect:")
      choice = menu.show

      if choice && choice <= squads.length
        show_detailed_squad_info(squads[choice - 1])
      else
        break  # Return to main menu
      end
    end
  end

  def show_detailed_squad_info(squad)
    system('clear') || system('cls')

    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   SQUAD PERSONNEL FILE                ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🪖 SQUAD: #{squad.name.upcase}"
    puts "👥 ACTIVE PERSONNEL: #{squad.soldiers.count}"
    puts "=" * 60
    puts

    if squad.soldiers.empty?
      puts "❌ No active personnel in this squad."
      puts "   Squad has been completely eliminated in action."
    else
      # Calculate squad statistics
      total_missions = squad.soldiers.count { |s| s.total_skill > 80 }  # Rough estimate of experienced soldiers
      avg_skill = squad.soldiers.sum(&:total_skill) / squad.soldiers.count
      veterans = squad.soldiers.count { |s| s.total_skill > 90 }

      puts "📊 SQUAD OVERVIEW:"
      puts "   Average Skill Level: #{avg_skill}"
      puts "   Veterans (90+ skill): #{veterans}"
      puts "   Combat Experience: #{total_missions > 0 ? 'Experienced' : 'Fresh recruits'}"
      puts

      puts "👤 PERSONNEL ROSTER:"
      puts "-" * 60

      squad.soldiers.each_with_index do |soldier, index|
        puts "#{index + 1}. #{soldier.name.upcase}"
        puts "   Skills: Offense #{soldier.offense} | Defense #{soldier.defense} | Grit #{soldier.grit} | Leadership #{soldier.leadership}"
        puts "   Total Skill: #{soldier.total_skill} | Status: #{get_soldier_status_description(soldier)}"

        # Show background information
        if soldier.background
          puts "   Background: #{soldier.background}"
        elsif soldier.total_skill < 80
          puts "   Background: Recently recruited soldier"
        elsif soldier.name.include?('"')
          puts "   Background: Veteran operative with field callsign"
        else
          background = get_soldier_background(soldier)
          if background
            puts "   Background: #{background}"
          else
            puts "   Background: Regular forces personnel"
          end
        end

        puts "   Combat Readiness: #{get_combat_readiness(soldier)}"
        puts
      end
    end

    puts "=" * 60
    puts "Press Enter to return to squad selection..."
    gets
  end

  def get_soldier_status_description(soldier)
    case soldier.status
    when :alive
      "Ready for deployment"
    when :injured
      "Wounded but operational"
    when :shaken
      "Psychologically affected"
    when :kia
      "Killed in action"
    else
      "Active duty"
    end
  end

  def get_soldier_background(soldier)
    # This is a bit of a hack - we'll try to determine background from skill patterns
    # Since we cleaned the names, we can't recover the original profession
    # But we can make educated guesses based on skill distribution

    if soldier.offense > soldier.defense && soldier.offense > soldier.grit
      if soldier.offense >= 25
        "Combat Specialist - Assault Operations"
      else
        "Infantry - Frontline Combat"
      end
    elsif soldier.defense > soldier.offense && soldier.defense > soldier.leadership
      if soldier.defense >= 25
        "Defensive Specialist - Fortification Expert"
      else
        "Heavy Armor - Defensive Operations"
      end
    elsif soldier.leadership > 20
      if soldier.leadership >= 25
        "Command Personnel - Tactical Leadership"
      else
        "Squad Leader - Field Command"
      end
    elsif soldier.grit > 20
      if soldier.grit >= 25
        "Special Operations - High-Risk Missions"
      else
        "Reconnaissance - Survival Specialist"
      end
    else
      nil  # Will show generic background
    end
  end

  def get_combat_readiness(soldier)
    total = soldier.total_skill

    if total >= 110
      "🟢 Elite (Exceptional)"
    elsif total >= 90
      "🟢 Veteran (High)"
    elsif total >= 75
      "🟡 Experienced (Good)"
    elsif total >= 60
      "🟡 Competent (Average)"
    else
      "🔴 Rookie (Needs Training)"
    end
  end

  def handle_how_to_play
    system('clear') || system('cls')

    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                     HOW TO PLAY                       ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎯 OBJECTIVE:"
    puts "   Command elite squads to defend cities from kaiju attacks!"
    puts
    puts "🪖 SOLDIER SKILLS:"
    puts "   Each soldier has 4 skills that determine combat effectiveness:"
    puts "   • OFFENSE: Attack power and damage dealing"
    puts "   • DEFENSE: Armor and damage resistance"
    puts "   • GRIT: Mental toughness and survival instinct"
    puts "   • LEADERSHIP: Coordination and team effectiveness"
    puts
    puts "⚔️  COMBAT SYSTEM:"
    puts "   • Attack Power = Offense + (Leadership ÷ 2)"
    puts "   • Survival Chance = Defense + (Grit ÷ 2)"
    puts "   • Weak soldiers (low total skills) face extra penalties"
    puts "   • Veterans (90+ total skill) earn nicknames and callsigns"
    puts
    puts "🎯 RISK ASSESSMENT:"
    puts "   Each soldier shows color-coded risk vs specific kaiju:"
    puts "   🟢 Low Risk    🟡 Moderate Risk    🟠 High Risk    🔴 Extreme Risk"
    puts
    puts "📈 PROGRESSION:"
    puts "   • Soldiers improve skills through successful missions"
    puts "   • Casualties are automatically replaced with recruits"
    puts "   • Campaign statistics track your command performance"
    puts
    puts "🎮 NAVIGATION:"
    puts "   • Use ↑↓ arrow keys to navigate menus"
    puts "   • Press Enter to select, or use number keys (1-9)"
    puts "   • Press Q to quit from most menus"
    puts
    puts "🎌 Good luck, Commander! The world is counting on you!"
    puts
    puts "Press Enter to return to main menu..."
    gets
  end

  def handle_about_game
    system('clear') || system('cls')

    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   ABOUT THE GAME                      ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎌 KAIJU DEFENSE FORCE v2.0"
    puts "   A strategic text-based kaiju combat simulator"
    puts
    puts "✨ ENHANCED FEATURES:"
    puts "   • Sophisticated 4-skill soldier system"
    puts "   • Dynamic risk assessment and tactical intelligence"
    puts "   • Rich narrative battle system with progressive reporting"
    puts "   • Persistent dual-squad management"
    puts "   • Enhanced naming systems for soldiers and kaiju"
    puts "   • Arrow key navigation for classic console game feel"
    puts "   • Mission persistence and city destruction consequences"
    puts "   • Comprehensive campaign statistics and progression"
    puts
    puts "🎯 GAMEPLAY FEATURES:"
    puts "   • Two specialized squads with unique generated names"
    puts "   • Veteran soldiers earn nicknames and callsigns"
    puts "   • Automatic recruitment maintains squad viability"
    puts "   • Save/load system preserves campaign progress"
    puts "   • Mission rejection with realistic consequences"
    puts "   • Enhanced battle text with skill-aware narratives"
    puts
    puts "🚀 TECHNICAL FEATURES:"
    puts "   • Clean terminal interface with screen clearing"
    puts "   • Professional menu system with arrow key navigation"
    puts "   • Robust save/load functionality"
    puts "   • Error handling and graceful fallbacks"
    puts
    puts "👨‍💻 Created for tactical strategy enthusiasts who appreciate"
    puts "    deep gameplay systems and immersive storytelling!"
    puts
    puts "Press Enter to return to main menu..."
    gets
  end

  def handle_quit_game
    system('clear') || system('cls')
    puts
    puts "🎌 Thanks for playing KAIJU DEFENSE FORCE!"
    puts "   The world will remember your service, Commander!"
    puts
  end
end
