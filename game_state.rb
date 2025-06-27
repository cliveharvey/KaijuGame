#!/usr/bin/env ruby

require 'json'
require 'ostruct'
require_relative 'models/squad'
require_relative 'models/soldier'
require_relative 'generators/soldier_name_generator'
require_relative 'generators/squad_name_generator'

class GameState
  SAVE_FILE = 'kaiju_save.json'

  attr_reader :squad_alpha, :squad_bravo, :missions_completed, :victories, :defeats, :total_kaiju_defeated, :soldiers_lost, :recruits_added, :pending_mission, :cities_destroyed

    def initialize(skip_squad_creation = false)
    @squad_alpha = nil
    @squad_bravo = nil
    @missions_completed = 0
    @victories = 0
    @defeats = 0
    @total_kaiju_defeated = 0
    @soldiers_lost = 0
    @recruits_added = 0
    @pending_mission = nil
    @cities_destroyed = 0

    # Auto-create squads for web interface (unless we're deserializing)
    create_new_squads_if_needed unless skip_squad_creation
  end

  def save_game
          save_data = {
        squad_alpha: serialize_squad(@squad_alpha),
        squad_bravo: serialize_squad(@squad_bravo),
      missions_completed: @missions_completed,
      victories: @victories,
      defeats: @defeats,
      total_kaiju_defeated: @total_kaiju_defeated,
      soldiers_lost: @soldiers_lost,
      recruits_added: @recruits_added,
      pending_mission: serialize_pending_mission(@pending_mission),
      cities_destroyed: @cities_destroyed
    }

    File.write(SAVE_FILE, JSON.pretty_generate(save_data))
    puts "💾 Game saved successfully!"
  rescue => e
    puts "❌ Error saving game: #{e.message}"
  end

  def load_game
    return false unless File.exist?(SAVE_FILE)

    save_data = JSON.parse(File.read(SAVE_FILE))

          @squad_alpha = deserialize_squad(save_data['squad_alpha'])
      @squad_bravo = deserialize_squad(save_data['squad_bravo'])
    @missions_completed = save_data['missions_completed'] || 0
    @victories = save_data['victories'] || 0
    @defeats = save_data['defeats'] || 0
    @total_kaiju_defeated = save_data['total_kaiju_defeated'] || 0
    @soldiers_lost = save_data['soldiers_lost'] || 0
    @recruits_added = save_data['recruits_added'] || 0
    @pending_mission = deserialize_pending_mission(save_data['pending_mission'])
    @cities_destroyed = save_data['cities_destroyed'] || 0

    puts "💿 Game loaded successfully!"
    puts "📊 Campaign Status: #{@missions_completed} missions, #{@victories} victories, #{@defeats} defeats"
    true
  rescue => e
    puts "❌ Error loading game: #{e.message}"
    false
  end

  def save_exists?
    File.exist?(SAVE_FILE)
  end

  def delete_save
    File.delete(SAVE_FILE) if File.exist?(SAVE_FILE)
    puts "🗑️  Save file deleted"
  end

  def create_new_squads
    # Generate unique squad names
    squad_names = SquadNameGenerator.generate_pair_of_squad_names

    @squad_alpha = Squad.new(squad_names[0], 5)
    @squad_bravo = Squad.new(squad_names[1], 5)
    puts "🆕 New squads created: #{@squad_alpha.name} and #{@squad_bravo.name}"
  end

  def create_new_squads_if_needed
    if @squad_alpha.nil? || @squad_bravo.nil?
      create_new_squads
    end
  end

  def record_mission_result(success, victory, casualties)
    @missions_completed += 1
    if success
      @victories += 1
      @total_kaiju_defeated += 1
    else
      @defeats += 1
    end
    @soldiers_lost += casualties
  end

  def add_recruits_to_squad(squad, count)
    return if count <= 0

    count.times do
      recruit = create_recruit
      # Show recruitment with profession
      recruit_name_with_profession = recruit.name
      puts "📝 #{recruit_name_with_profession} has been recruited to #{squad.name}"

      # Extract and store background separately
      recruit.background = extract_background_from_name(recruit.name)

      # Clean up name by removing profession for normal display
      recruit.name = clean_recruit_name(recruit.name)

      squad.soldiers << recruit
      @recruits_added += 1
    end
  end

  def get_squads
    [@squad_alpha, @squad_bravo]
  end

  def show_campaign_stats
    puts "\n" + "=" * 60
    puts "📊 CAMPAIGN STATISTICS"
    puts "=" * 60
    puts "🎯 Missions Completed: #{@missions_completed}"
    puts "🏆 Victories: #{@victories}"
    puts "💥 Defeats: #{@defeats}"
    puts "👹 Kaiju Defeated: #{@total_kaiju_defeated}"
    puts "🏙️  Cities Destroyed: #{@cities_destroyed}"
    puts "⚰️  Soldiers Lost: #{@soldiers_lost}"
    puts "🆕 Recruits Added: #{@recruits_added}"

    if @missions_completed > 0
      win_rate = (@victories.to_f / @missions_completed * 100).round(1)
      puts "📈 Win Rate: #{win_rate}%"
    end

    puts "\n🪖 SQUAD STATUS:"
    [@squad_alpha, @squad_bravo].compact.each do |squad|
      puts "   #{squad.name}: #{squad.soldiers.count} soldiers"
      if squad.soldiers.any?
        veteran_count = squad.soldiers.count { |s| s.total_skill > 90 }
        avg_skill = squad.soldiers.sum(&:total_skill) / squad.soldiers.count
        puts "     Average Skill: #{avg_skill}, Veterans: #{veteran_count}"
      end
    end
  end

  def show_squad_selection(kaiju)
    clear_screen  # Clear screen for squad selection

    puts "\n" + "=" * 60
    puts "📋 SQUAD SELECTION"
    puts "=" * 60
    puts "🎯 Choose which squad to deploy against the #{kaiju.size} #{kaiju.creature}:"
    puts "   \"#{kaiju.name_english}\" (Threat Level: #{kaiju.difficulty})"
    puts

    squads = get_squads
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. #{squad.name.upcase}"
      squad.show_squad_details(kaiju)
      puts
    end

    puts "DEPLOYMENT OPTIONS:"
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. Deploy #{squad.name}"
    end
    puts "3. Cancel mission and return to base"
    print "Enter your choice (1-3): "

    choice = gets.chomp.to_i
    clear_screen  # Clear after input

    case choice
    when 1
      squads[0]
    when 2
      squads[1] if squads[1]
    when 3
      puts "📋 Mission cancelled. Returning to base..."
      puts "Press Enter to continue..."
      gets
      nil
    else
      puts "❌ Invalid choice!"
      puts "Press Enter to try again..."
      gets
      show_squad_selection(kaiju)
    end
  end

  def show_squad_selection_for_mission(pending_mission)
    clear_screen

    kaiju_data = pending_mission[:kaiju]
    location_data = pending_mission[:location]

    puts "\n" + "=" * 60
    puts "📋 SQUAD DEPLOYMENT"
    puts "=" * 60
    puts "🎯 Mission: Engage #{kaiju_data[:name_english]} at #{location_data[:city]}"
    puts "⚠️  Threat Level: #{kaiju_data[:difficulty]} | Type: #{kaiju_data[:size].capitalize} #{kaiju_data[:creature]}"
    puts

    squads = get_squads
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. #{squad.name.upcase}"
      # Create temp kaiju object for risk assessment
      temp_kaiju = OpenStruct.new(kaiju_data)
      squad.show_squad_details(temp_kaiju)
      puts
    end

    puts "DEPLOYMENT OPTIONS:"
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. Deploy #{squad.name}"
    end
    puts "3. Cancel mission and return to mission briefing"
    print "Enter your choice (1-3): "

    choice = gets.chomp.to_i
    clear_screen

    case choice
    when 1
      squads[0]
    when 2
      squads[1] if squads[1]
    when 3
      puts "📋 Mission deployment cancelled."
      puts "Returning to mission briefing..."
      puts "Press Enter to continue..."
      gets
      nil
    else
      puts "❌ Invalid choice!"
      puts "Press Enter to try again..."
      gets
      show_squad_selection_for_mission(pending_mission)
    end
  end

  def set_pending_mission(kaiju, location)
    @pending_mission = {
      kaiju: {
        name_english: kaiju.name_english,
        name_monster: kaiju.name_monster,
        size: kaiju.size,
        creature: kaiju.creature,
        characteristic: kaiju.characteristic,
        material: kaiju.material,
        weapon: kaiju.weapon,
        difficulty: kaiju.difficulty,
        offense: kaiju.offense,
        defense: kaiju.defense,
        speed: kaiju.speed,
        special: kaiju.special
      },
      location: {
        city: location.city
      }
    }
  end

  def clear_pending_mission
    @pending_mission = nil
  end

  def has_pending_mission?
    !@pending_mission.nil?
  end

  def record_city_destruction
    @cities_destroyed += 1
  end

  def generate_destruction_description(kaiju_data, location_data)
    threat_level = kaiju_data[:difficulty]
    city = location_data[:city]
    creature_name = kaiju_data[:name_english]
    size = kaiju_data[:size]
    creature_type = kaiju_data[:creature]

    if threat_level >= 80
      # Complete destruction
      [
        "💀 CATASTROPHIC DESTRUCTION REPORT 💀",
        "#{city} has been completely obliterated by #{creature_name}.",
        "The #{size} #{creature_type} left nothing but rubble and ash in its wake.",
        "Casualty estimates: Total population loss",
        "Infrastructure: 100% destroyed",
        "The city has been wiped from the map forever.",
        "📺 International news reports this as one of the worst kaiju disasters in history."
      ]
    elsif threat_level >= 60
      # Severe destruction
      [
        "🔥 SEVERE DESTRUCTION REPORT 🔥",
        "#{city} has suffered catastrophic damage from #{creature_name}.",
        "The #{size} #{creature_type} destroyed most of the city center and key infrastructure.",
        "Casualty estimates: 70-85% of population",
        "Infrastructure: 80% destroyed",
        "The few survivors have evacuated to neighboring regions.",
        "📺 Emergency services report the city is uninhabitable."
      ]
    elsif threat_level >= 40
      # Major destruction
      [
        "💥 MAJOR DESTRUCTION REPORT 💥",
        "#{city} has been heavily damaged by #{creature_name}.",
        "The #{size} #{creature_type} rampaged through several districts before departing.",
        "Casualty estimates: 40-60% of population",
        "Infrastructure: 60% destroyed",
        "Evacuation efforts are underway for remaining civilians.",
        "📺 The city will require years of rebuilding."
      ]
    else
      # Moderate destruction
      [
        "⚠️ DESTRUCTION REPORT ⚠️",
        "#{city} has sustained significant damage from #{creature_name}.",
        "The #{size} #{creature_type} caused widespread destruction before moving on.",
        "Casualty estimates: 20-35% of population",
        "Infrastructure: 40% destroyed",
        "Emergency services are providing aid to survivors.",
        "📺 The city is declared a disaster zone but remains inhabited."
      ]
    end
  end

  # Serialize game state to hash for web sessions
  def to_hash
    {
      'squad_alpha' => serialize_squad(@squad_alpha),
      'squad_bravo' => serialize_squad(@squad_bravo),
      'missions_completed' => @missions_completed,
      'victories' => @victories,
      'defeats' => @defeats,
      'total_kaiju_defeated' => @total_kaiju_defeated,
      'soldiers_lost' => @soldiers_lost,
      'recruits_added' => @recruits_added,
      'pending_mission' => serialize_pending_mission(@pending_mission),
      'cities_destroyed' => @cities_destroyed
    }
  end

  # Deserialize game state from hash
  def self.from_hash(hash)
    return new unless hash

    game_state = new(true)  # Skip squad creation during deserialization
    game_state.instance_variable_set(:@squad_alpha, game_state.deserialize_squad(hash['squad_alpha']))
    game_state.instance_variable_set(:@squad_bravo, game_state.deserialize_squad(hash['squad_bravo']))
    game_state.instance_variable_set(:@missions_completed, hash['missions_completed'] || 0)
    game_state.instance_variable_set(:@victories, hash['victories'] || 0)
    game_state.instance_variable_set(:@defeats, hash['defeats'] || 0)
    game_state.instance_variable_set(:@total_kaiju_defeated, hash['total_kaiju_defeated'] || 0)
    game_state.instance_variable_set(:@soldiers_lost, hash['soldiers_lost'] || 0)
    game_state.instance_variable_set(:@recruits_added, hash['recruits_added'] || 0)
    game_state.instance_variable_set(:@pending_mission, game_state.deserialize_pending_mission(hash['pending_mission']))
    game_state.instance_variable_set(:@cities_destroyed, hash['cities_destroyed'] || 0)
    game_state
  end

  def get_missions_completed
    @missions_completed
  end

  def get_cities_destroyed
    @cities_destroyed
  end

  def serialize_squad(squad)
    return nil unless squad

    {
      'name' => squad.name,
      'soldiers' => squad.soldiers.map { |soldier| serialize_soldier(soldier) }
    }
  end

  def deserialize_squad(squad_data)
    return nil unless squad_data

    squad = Squad.new(squad_data['name'], 0)  # Start with 0 soldiers
    squad.soldiers = squad_data['soldiers'].map { |soldier_data| deserialize_soldier(soldier_data) }
    squad
  end

  def serialize_soldier(soldier)
    {
      'name' => soldier.name,
      'offense' => soldier.offense,
      'defense' => soldier.defense,
      'grit' => soldier.grit,
      'leadership' => soldier.leadership,
      'status' => soldier.status.to_s,
      'success' => soldier.success,
      'background' => soldier.background,
      'level' => soldier.level,
      'experience' => soldier.experience,
      'experience_to_next_level' => soldier.experience_to_next_level,
      'missions_completed' => soldier.missions_completed
    }
  end

  def deserialize_soldier(soldier_data)
    soldier = Soldier.new(nil,
                         soldier_data['offense'],
                         soldier_data['defense'],
                         soldier_data['grit'],
                         soldier_data['leadership'])

    soldier.name = soldier_data['name']
    soldier.status = soldier_data['status'].to_sym
    soldier.success = soldier_data['success']
    soldier.background = soldier_data['background']
    soldier.level = soldier_data['level'] || 1
    soldier.experience = soldier_data['experience'] || 0
    soldier.experience_to_next_level = soldier_data['experience_to_next_level'] || 0
    soldier.missions_completed = soldier_data['missions_completed'] || 0

    soldier
  end

  def serialize_pending_mission(mission)
    return nil unless mission && mission[:kaiju] && mission[:location]

    {
      kaiju: {
        name_english: mission[:kaiju][:name_english],
        name_monster: mission[:kaiju][:name_monster],
        size: mission[:kaiju][:size],
        creature: mission[:kaiju][:creature],
        characteristic: mission[:kaiju][:characteristic],
        material: mission[:kaiju][:material],
        weapon: mission[:kaiju][:weapon],
        difficulty: mission[:kaiju][:difficulty],
        offense: mission[:kaiju][:offense],
        defense: mission[:kaiju][:defense],
        speed: mission[:kaiju][:speed],
        special: mission[:kaiju][:special]
      },
      location: {
        city: mission[:location][:city]
      }
    }
  end

  def deserialize_pending_mission(mission_data)
    return nil unless mission_data && (mission_data[:kaiju] || mission_data['kaiju']) && (mission_data[:location] || mission_data['location'])

    # Handle both symbol and string keys
    kaiju_data = mission_data[:kaiju] || mission_data['kaiju']
    location_data = mission_data[:location] || mission_data['location']

    {
      kaiju: {
        name_english: kaiju_data[:name_english] || kaiju_data['name_english'],
        name_monster: kaiju_data[:name_monster] || kaiju_data['name_monster'],
        size: kaiju_data[:size] || kaiju_data['size'],
        creature: kaiju_data[:creature] || kaiju_data['creature'],
        characteristic: kaiju_data[:characteristic] || kaiju_data['characteristic'],
        material: kaiju_data[:material] || kaiju_data['material'],
        weapon: kaiju_data[:weapon] || kaiju_data['weapon'],
        difficulty: kaiju_data[:difficulty] || kaiju_data['difficulty'],
        offense: kaiju_data[:offense] || kaiju_data['offense'] || 0,
        defense: kaiju_data[:defense] || kaiju_data['defense'] || 0,
        speed: kaiju_data[:speed] || kaiju_data['speed'] || 0,
        special: kaiju_data[:special] || kaiju_data['special'] || 0
      },
      location: {
        city: location_data[:city] || location_data['city']
      }
    }
  end

  private

  def clean_recruit_name(name_with_profession)
    # Remove profession from recruit names like "John Smith (Demolitions Expert)" -> "John Smith"
    name_with_profession.gsub(/\s*\([^)]+\)$/, '')
  end

  def extract_background_from_name(name_with_profession)
    # Extract profession from recruit names like "John Smith (Demolitions Expert)" -> "Demolitions Expert"
    match = name_with_profession.match(/\(([^)]+)\)$/)
    match ? match[1] : nil
  end

  def create_recruit
    # Create a medium-low skill recruit (12-20 range instead of 10-30)
    recruit = Soldier.new(
      nil,                  # name will be generated in Soldier class
      rand(12..20),         # offense
      rand(12..20),         # defense
      rand(12..20),         # grit
      rand(12..20)          # leadership
    )

    # Override with specialized recruit name that includes background
    recruit.name = SoldierNameGenerator.generate_recruit_name
    recruit
  end

  def clear_screen
    begin
      system('clear') || system('cls')
    rescue
      # If screen clearing fails, just continue
      puts "\n" * 3  # Add some space instead
    end
  end
end
