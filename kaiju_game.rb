#!/usr/bin/env ruby

class Soldier
  CONSONANTS = %w[b c d f g h j k l m n p q r s sh zh t v w x].freeze
  VOWELS = %w[a e i o u ae y].freeze

  attr_accessor :name, :skill, :status, :success

  def initialize(name_length = rand(3..8), skill = rand(10..35))
    @name = generate_name(name_length)
    @skill = skill
    @status = :alive
    @success = false
  end

  def combat(difficulty)
    combat_roll = rand(@skill)

    case combat_roll
    when 0..(difficulty - 30)
      @status = :kia
      false
    when (difficulty - 30)..(difficulty - 20)
      @status = :injured
      @skill += difficulty / 2
      false
    when (difficulty - 20)..(difficulty - 10)
      @status = :shaken
      @skill += difficulty / 2
      @success = true
    else
      @skill += difficulty
      @success = true
    end
  end

  private

  def generate_name(length)
    name = CONSONANTS.sample.capitalize + VOWELS.sample
    (length - 2).times do |i|
      name += i.even? ? CONSONANTS.sample : VOWELS.sample
    end
    name
  end
end

class Squad
  attr_reader :name, :soldiers

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5)
    @name = name
    @soldiers = soldier_count.times.map { Soldier.new }
  end

  def combat(difficulty)
    @soldiers.each { |soldier| soldier.combat(difficulty) }
    @soldiers.count(&:success) >= 3
  end
end

class Kaiju
  SIZES = [:small, :medium, :large, :huge, :massive, :gigantic].freeze

  CREATURES = %w[
    alligator allosaurus ape aurochs baboon badger bat bear hawk boar
    brontosaurus camel cat cow crab crocodile deer deinonychus dimetrodon
    dragon eagle elephant elk snake frog fungus golem gorilla horse hydra
    minotaur ooze ostrich ox spider squid tiger sloth slug
  ].freeze

  MATERIALS = {
    flesh: %w[leathery skinless rash_covered rotting],
    rock: %w[limestone granite obsidian pumice shale],
    gem: %w[jade diamond gypsum opal quartz jasper],
    metal: %w[iron steel bronze tin copper aluminum gold silver titanium],
    other: %w[clay glass wood refuse ice wool]
  }.freeze

  CHARACTERISTICS = {
    appearance: ['putrid stinky odour', 'glowing red eyes', 'massive claws', 'razor sharp teeth'],
    movement: ['lightning fast', 'earth shaking steps', 'silent stalking', 'erratic twitching'],
    special: ['acidic breath', 'regenerating wounds', 'mind control powers', 'invisible when still']
  }.freeze

  WEAPONS = {
    melee: ['razor sharp claws', 'bone crushing jaws', 'whip-like tail', 'massive fists'],
    ranged: ['acid spit', 'lightning breath', 'sonic roar', 'explosive spores'],
    psychic: ['mind blast', 'fear aura', 'confusion waves', 'nightmare projection']
  }.freeze

  attr_reader :name_english, :name_monster, :size, :creature, :material,
              :characteristic, :weapon, :difficulty

  def initialize
    @size = SIZES.sample
    @difficulty = (SIZES.index(@size) + 1) * 10
    @creature = CREATURES.sample
    @material = MATERIALS.values.flatten.sample
    @characteristic = CHARACTERISTICS.values.flatten.sample
    @weapon = WEAPONS.values.flatten.sample

    generate_names
  end

  private

  def generate_names
    # Simplified name generation - could be much more elaborate
    @name_english = "#{random_syllable.capitalize}#{random_syllable} #{adjective_name}"
    @name_monster = "#{random_syllable.capitalize}#{random_syllable} #{random_syllable.capitalize}#{random_syllable}"
  end

  def random_syllable
    Soldier::CONSONANTS.sample + Soldier::VOWELS.sample
  end

  def adjective_name
    ["the Destroyer", "the Terrible", "Devourer of Cities", "the Ancient One",
     "the Unstoppable", "the Nightmare", "the Silent Death"].sample
  end
end

class Location
  CITIES = [
    "Prague, Czech Republic", "Istanbul, Turkey", "Jerusalem, Israel",
    "Accra, Ghana", "Colombo, Sri Lanka", "Buenos Aires, Argentina",
    "Reykjavík, Iceland", "Denver, United States", "Abuja, Nigeria",
    "Nashville, TN, United States", "Bratislava, Slovakia", "Lima, Peru"
  ].freeze

  attr_reader :city

  def initialize
    @city = CITIES.sample
  end
end

class KaijuGame
  STATUS_ICONS = {
    alive: "✅",
    shaken: "⚡",
    injured: "🩹",
    kia: "💀"
  }.freeze

  def initialize
    puts "╔════════════════════════════════════════════════════════╗"
    puts "║                   KAIJU DEFENSE FORCE                  ║"
    puts "║                    Text Adventure                       ║"
    puts "╚════════════════════════════════════════════════════════╝"
    puts
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

    show_battle(squad, kaiju)
  end

  def show_squad(squad)
    puts "\n📋 ASSEMBLING SQUAD: #{squad.name}"
    puts "Members:"
    squad.soldiers.each_with_index do |soldier, i|
      puts "  #{i + 1}. #{soldier.name} (Skill: #{soldier.skill})"
    end
  end

  def show_battle(squad, kaiju)
    system('clear') || system('cls')  # Cross-platform clear

    puts "⚔️  BATTLE REPORT ⚔️"
    puts "\n\"#{kaiju.name_english}\" the #{kaiju.size} #{kaiju.creature} has made landfall!"
    puts

    success = squad.combat(kaiju.difficulty)

    # Show individual soldier outcomes
    squad.soldiers.each do |soldier|
      puts "🪖 #{soldier.name}:"

      if soldier.success
        puts "   ✓ Moved tactically into position"
        puts "   ✓ Successfully engaged the kaiju"
        puts "   ✓ Made a significant impact"
      else
        puts "   ✗ Struggled to find good positioning"
        puts "   ✗ Had difficulty with the massive enemy"
        puts "   ✗ Was overwhelmed by the kaiju's power"
      end

      if soldier.status != :alive
        puts "   #{STATUS_ICONS[soldier.status]} #{soldier.name} was #{soldier.status.to_s.upcase}!"
      end
      puts
    end

    # Show mission outcome
    puts "-" * 50
    if success
      puts "🎉 MISSION SUCCESSFUL!"
      puts "The kaiju has been defeated and the city is saved!"
    else
      puts "💥 MISSION FAILED"
      puts "The kaiju continues its rampage..."
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

# Run the game
if __FILE__ == $0
  game = KaijuGame.new
  game.play
end
