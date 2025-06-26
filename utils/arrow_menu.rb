#!/usr/bin/env ruby
require 'io/console'

class ArrowMenu
  def initialize(options, title, subtitle = nil)
    @options = options
    @title = title
    @subtitle = subtitle
    @selected = 0
  end

  def show
    loop do
      display_menu

      case STDIN.getch
      when "\e"    # Escape sequence
        case STDIN.getch
        when "["   # Arrow key sequence
          case STDIN.getch
          when "A" # Up arrow
            @selected = (@selected - 1) % @options.length
          when "B" # Down arrow
            @selected = (@selected + 1) % @options.length
          end
        end
      when "\r", "\n" # Enter key
        return @selected + 1  # Return 1-based index to match existing system
      when "\u0003"   # Ctrl+C
        puts "\nExiting..."
        exit
      when "q", "Q"   # Quit
        return nil
      when "1".."9"   # Number keys for quick selection
        num = $&.to_i
        if num >= 1 && num <= @options.length
          return num
        end
      end
    end
  end

  private

  def display_menu
    system('clear') || system('cls')

    # Title with fancy border (matching your game's style)
    puts "╔" + "═" * (@title.length + 2) + "╗"
    puts "║ #{@title} ║"
    puts "╚" + "═" * (@title.length + 2) + "╝"
    puts

    # Subtitle if provided
    if @subtitle
      puts @subtitle
      puts
    end

    # Menu options with selection highlighting
    @options.each_with_index do |option, index|
      if index == @selected
        puts "  ▶ #{index + 1}. #{option} ◀"  # Highlighted option
      else
        puts "    #{index + 1}. #{option}"     # Normal option
      end
    end

    puts
    puts "🎮 Use ↑↓ arrows or 1-#{@options.length} keys, Enter to select, Q to quit"
  end
end

# Specialized menu for mission choices
class MissionMenu < ArrowMenu
  def initialize(kaiju_name, location, threat_level)
    title = "🚨 KAIJU ALERT! 🚨"
    subtitle = "🎯 Target: #{kaiju_name} at #{location} | ⚠️ Threat Level: #{threat_level}"

    options = [
      "✅ Accept Mission - Deploy forces to engage",
      "❌ Reject Mission - Stay at base (city will be attacked)",
      "🏠 Return to Main Menu - Save and exit"
    ]

    super(options, title, subtitle)
  end
end

# Specialized menu for squad selection
class SquadMenu < ArrowMenu
  def initialize(squads, kaiju_name, location)
    title = "📋 SQUAD DEPLOYMENT"
    subtitle = "🎯 Mission: Engage #{kaiju_name} at #{location}"

    options = squads.map { |squad| "Deploy #{squad.name}" }
    options << "Cancel mission and return to briefing"

    super(options, title, subtitle)
  end
end
