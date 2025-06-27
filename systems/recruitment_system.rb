#!/usr/bin/env ruby

class RecruitmentSystem
  def initialize
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
