#!/usr/bin/env ruby

class MainMenu
  def initialize(game_instance, game_title = "KAIJU DEFENSE FORCE", game_subtitle = "Text Adventure")
    @game = game_instance
    @game_title = game_title
    @game_subtitle = game_subtitle
  end

  def show_main_menu
    system('clear') || system('cls')
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   #{@game_title.center(22)}                  ║"
    puts "║                    #{@game_subtitle.center(21)}                       ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎌 Welcome, Commander! The world needs your leadership!"
    puts
    puts "Main Menu:"
    puts "1. 🚀 Start New Mission"
    puts "2. 📖 How to Play"
    puts "3. 🌟 About the Game"
    puts "4. 🚪 Quit Game"
    puts
    print "Enter your choice (1-4): "
  end

  def show_instructions
    system('clear') || system('cls')
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                     HOW TO PLAY                        ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎯 OBJECTIVE:"
    puts "   Command elite squads to defend cities from kaiju attacks!"
    puts
    puts "🪖 YOUR SQUAD:"
    puts "   • Each soldier has 4 skills: Offense, Defense, Grit, Leadership"
    puts "   • Offense: Determines attack power and damage potential"
    puts "   • Defense: Reduces chance of injury and death"
    puts "   • Grit: Improves survival chances and recovery"
    puts "   • Leadership: Enhances attack coordination and team effectiveness"
    puts "   • Soldiers can be killed, injured, or shaken in battle"
    puts "   • You need at least 3 successful soldiers to win a mission"
    puts "   • Successful combat improves all skills through experience"
    puts
    puts "👹 KAIJU THREATS:"
    puts "   • Each kaiju has a different size and threat level"
    puts "   • Larger kaiju are more dangerous but offer greater rewards"
    puts "   • Every kaiju has unique characteristics and weapons"
    puts
    puts "🎮 GAMEPLAY:"
    puts "   • Choose whether to deploy your squad or let the city fall"
    puts "   • Watch the battle unfold and see your soldiers' fates"
    puts "   • Successful missions help your soldiers gain experience"
    puts "   • Can you save the world from the kaiju menace?"
    puts

    # Allow games to add their own specific instructions
    show_game_specific_instructions if @game.respond_to?(:show_game_specific_instructions)

    puts "\nPress Enter to return to main menu..."
    gets
  end

  def show_about
    system('clear') || system('cls')
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   ABOUT THE GAME                       ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
    puts "🎨 #{@game_title}"
    puts "   A Ruby-based strategy game inspired by classic kaiju films"
    puts
    puts "🎬 Features:"
    puts "   • Procedurally generated kaiju with unique characteristics"
    puts "   • Dynamic squad management with persistent soldier stats"
    puts "   • Multiple cities to defend around the world"
    puts "   • Rich combat narrative with detailed battle reports"
    puts

    # Allow games to add their own specific about information
    show_game_specific_about if @game.respond_to?(:show_game_specific_about)

    puts "🏆 Challenge yourself to:"
    puts "   • Save as many cities as possible"
    puts "   • Keep your soldiers alive and experienced"
    puts "   • Face increasingly dangerous kaiju threats"
    puts
    puts "🤖 Created during a hackathon as a text-based strategy game"
    puts "   combining elements of tactical combat and monster hunting!"
    puts
    puts "\nPress Enter to return to main menu..."
    gets
  end

  def run
    loop do
      show_main_menu
      choice = gets.chomp

      case choice
      when "1"
        @game.play
      when "2"
        show_instructions
      when "3"
        show_about
      when "4"
        puts "\n🎌 Thanks for playing #{@game_title}!"
        puts "   The world will remember your service, Commander!"
        break
      else
        puts "\n❌ Invalid choice! Please enter 1-4."
        puts "Press Enter to continue..."
        gets
      end
    end
  end

  private

  def show_game_specific_instructions
    @game.show_game_specific_instructions
  end

  def show_game_specific_about
    @game.show_game_specific_about
  end
end
