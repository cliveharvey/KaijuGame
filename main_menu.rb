#!/usr/bin/env ruby

class MainMenu
  def initialize(game_instance, game_state, game_title = "KAIJU DEFENSE FORCE", game_subtitle = "Text Adventure")
    @game = game_instance
    @game_state = game_state
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

    # Show different menu based on whether save exists
    if @game_state.save_exists?
      puts "Campaign Menu:"
      puts "1. 🔄 Continue Campaign"
      puts "2. 🆕 New Campaign"
      puts "3. 📊 Campaign Statistics"
      puts "4. 📖 How to Play"
      puts "5. 🌟 About the Game"
      puts "6. 🚪 Quit Game"
      puts
      print "Enter your choice (1-6): "
    else
      puts "Main Menu:"
      puts "1. 🚀 Start New Campaign"
      puts "2. 📖 How to Play"
      puts "3. 🌟 About the Game"
      puts "4. 🚪 Quit Game"
      puts
      print "Enter your choice (1-4): "
    end
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
    puts "   • Build your squad over multiple missions and campaigns"
    puts "   • Can you save the world from the kaiju menace?"
    puts
    puts "💾 PERSISTENCE:"
    puts "   • Your squad and progress are automatically saved"
    puts "   • Soldiers gain experience and improve over time"
    puts "   • Track your campaign statistics and achievements"
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
    puts "   • Persistent squad management with soldier development"
    puts "   • Multiple cities to defend around the world"
    puts "   • Rich combat narrative with detailed battle reports"
    puts "   • Campaign progression and statistics tracking"
    puts

    # Allow games to add their own specific about information
    show_game_specific_about if @game.respond_to?(:show_game_specific_about)

    puts "🏆 Challenge yourself to:"
    puts "   • Save as many cities as possible"
    puts "   • Build an elite veteran squad"
    puts "   • Face increasingly dangerous kaiju threats"
    puts "   • Achieve the highest win rate possible"
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

      if @game_state.save_exists?
        case choice
        when "1"
          handle_continue_campaign
        when "2"
          handle_new_campaign
        when "3"
          @game_state.show_campaign_stats
          puts "\nPress Enter to continue..."
          gets
        when "4"
          show_instructions
        when "5"
          show_about
        when "6"
          puts "\n🎌 Thanks for playing #{@game_title}!"
          puts "   The world will remember your service, Commander!"
          break
        else
          puts "\n❌ Invalid choice! Please enter 1-6."
          puts "Press Enter to continue..."
          gets
        end
      else
        case choice
        when "1"
          handle_new_campaign
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
  end

  private

  def handle_continue_campaign
    if @game_state.load_game
      @game.play(@game_state)
    else
      puts "❌ Failed to load campaign. Starting new campaign instead."
      handle_new_campaign
    end
  end

  def handle_new_campaign
    if @game_state.save_exists?
      puts "\n⚠️  This will delete your existing campaign!"
      print "Are you sure? (y/n): "
      confirm = gets.chomp.downcase
      return unless confirm.start_with?('y')

      @game_state.delete_save
    end

    @game_state.create_new_squads
    @game.play(@game_state)
  end

  def show_game_specific_instructions
    @game.show_game_specific_instructions
  end

  def show_game_specific_about
    @game.show_game_specific_about
  end
end
