#!/usr/bin/env ruby

require_relative 'main_menu'
require_relative 'game_state'
require_relative 'systems/mission_manager'
require_relative 'systems/battle_system'
require_relative 'systems/recruitment_system'
require_relative 'utils/display_helper'

class KaijuGame
  include DisplayHelper

  def initialize
    @mission_manager = MissionManager.new
    @battle_system = BattleSystem.new
    @recruitment_system = RecruitmentSystem.new
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

    show_boxed_header("MISSION BRIEFING")
    puts

    # Show campaign status
    game_state.show_campaign_stats
    wait_for_input("\nPress Enter to continue to mission operations...")
    clear_screen

    # Main mission loop
    loop do
      # Check if there's a pending mission or generate new one
      unless game_state.has_pending_mission?
        @mission_manager.generate_new_mission(game_state)
      end

      # Show current mission using arrow menu
      mission_choice = @mission_manager.show_mission_briefing_with_menu(game_state.pending_mission)

      case mission_choice
      when 1 # Accept
        # Accept mission - proceed to squad selection
        clear_screen
        selected_squad = @mission_manager.show_squad_selection_with_menu(game_state.pending_mission, game_state)

        if selected_squad
          # Conduct the mission with already balanced kaiju
          result = conduct_accepted_mission(game_state.pending_mission, selected_squad, game_state)
          game_state.clear_pending_mission

          # Save after mission completion
          game_state.save_game

          # Ask if player wants to continue
          unless @mission_manager.continue_operations_with_menu?
            break
          end
        else
          # Player cancelled squad selection, keep the mission pending
          # Save game to preserve the mission
          game_state.save_game
        end

      when 2 # Reject
        # Reject mission - show destruction and generate new mission
        @mission_manager.show_mission_rejection_consequences(game_state.pending_mission, game_state)
        game_state.clear_pending_mission
        game_state.save_game

      when 3 # Main menu
        # Return to main menu - save current state including pending mission
        game_state.save_game
        puts "\n🏠 Returning to main menu..."
        puts "   Your current mission will be saved and available when you return."
        wait_for_input
        break
      end
    end

    puts "\n🎌 Mission operations complete! Returning to main menu..."
    wait_for_input
  end

  private

  def conduct_accepted_mission(pending_mission, squad, game_state)
    # Use the battle system to conduct the battle
    result = @battle_system.conduct_battle(pending_mission, squad, game_state)

    # Handle recruitment for KIA replacements
    @recruitment_system.handle_recruitment(squad, game_state, result[:casualties])

    # Return result
    result
  end
end

# Run the game
if __FILE__ == $0
  menu = MainMenu.new
  menu.run
end
