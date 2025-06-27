#!/usr/bin/env ruby

module DisplayHelper
  def clear_screen
    begin
      system('clear') || system('cls')
    rescue
      # If screen clearing fails, just continue
      puts "\n" * 3  # Add some space instead
    end
  end

  def show_separator(char = "=", length = 60)
    puts char * length
  end

  def show_header(title, char = "=", length = 60)
    puts char * length
    puts title.center(length)
    puts char * length
  end

  def show_boxed_header(title)
    border = "╔" + "═" * (title.length + 2) + "╗"
    content = "║ #{title} ║"
    bottom = "╚" + "═" * (title.length + 2) + "╝"

    puts border
    puts content
    puts bottom
  end

  def wait_for_input(message = "Press Enter to continue...")
    puts message
    gets
  end

  def show_loading_message(message, delay = 1.0)
    puts message
    sleep(delay)
  end
end
