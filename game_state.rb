#!/usr/bin/env ruby

require 'json'
require_relative 'models/squad'
require_relative 'generators/soldier_name_generator'
require_relative 'generators/squad_name_generator'

class GameState
  SAVE_FILE = 'kaiju_save.json'

  attr_accessor :squad_alpha, :squad_beta, :missions_completed, :victories, :defeats, :total_kaiju_defeated, :soldiers_lost, :recruits_added

  def initialize
    @squad_alpha = nil
    @squad_beta = nil
    @missions_completed = 0
    @victories = 0
    @defeats = 0
    @total_kaiju_defeated = 0
    @soldiers_lost = 0
    @recruits_added = 0
  end

  def save_game
    save_data = {
      squad_alpha: serialize_squad(@squad_alpha),
      squad_beta: serialize_squad(@squad_beta),
      missions_completed: @missions_completed,
      victories: @victories,
      defeats: @defeats,
      total_kaiju_defeated: @total_kaiju_defeated,
      soldiers_lost: @soldiers_lost,
      recruits_added: @recruits_added,
      last_saved: Time.now.to_s
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
    @squad_beta = deserialize_squad(save_data['squad_beta'])
    @missions_completed = save_data['missions_completed'] || 0
    @victories = save_data['victories'] || 0
    @defeats = save_data['defeats'] || 0
    @total_kaiju_defeated = save_data['total_kaiju_defeated'] || 0
    @soldiers_lost = save_data['soldiers_lost'] || 0
    @recruits_added = save_data['recruits_added'] || 0

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
    @squad_beta = Squad.new(squad_names[1], 5)
    puts "🆕 New squads created: #{@squad_alpha.name} and #{@squad_beta.name}"
  end

  def record_mission_result(victory, kaiju_defeated = false, casualties = 0)
    @missions_completed += 1
    if victory
      @victories += 1
      @total_kaiju_defeated += 1 if kaiju_defeated
    else
      @defeats += 1
    end
    @soldiers_lost += casualties
  end

  def add_recruits_to_squad(squad, count)
    return if count <= 0

    count.times do
      recruit = create_recruit
      squad.soldiers << recruit
      @recruits_added += 1
      puts "📝 #{recruit.name} has been recruited to #{squad.name}"
    end
  end

  def get_squads
    [@squad_alpha, @squad_beta].compact
  end

  def show_campaign_stats
    puts "\n" + "=" * 60
    puts "📊 CAMPAIGN STATISTICS"
    puts "=" * 60
    puts "🎯 Missions Completed: #{@missions_completed}"
    puts "🏆 Victories: #{@victories}"
    puts "💥 Defeats: #{@defeats}"
    puts "👹 Kaiju Defeated: #{@total_kaiju_defeated}"
    puts "⚰️  Soldiers Lost: #{@soldiers_lost}"
    puts "🆕 Recruits Added: #{@recruits_added}"

    if @missions_completed > 0
      win_rate = (@victories.to_f / @missions_completed * 100).round(1)
      puts "📈 Win Rate: #{win_rate}%"
    end

    puts "\n🪖 SQUAD STATUS:"
    [@squad_alpha, @squad_beta].compact.each do |squad|
      puts "   #{squad.name}: #{squad.soldiers.count} soldiers"
      if squad.soldiers.any?
        veteran_count = squad.soldiers.count { |s| s.total_skill > 90 }
        avg_skill = squad.soldiers.sum(&:total_skill) / squad.soldiers.count
        puts "     Average Skill: #{avg_skill}, Veterans: #{veteran_count}"
      end
    end
  end

  def show_squad_selection(kaiju)
    puts "\n" + "=" * 60
    puts "📋 SQUAD SELECTION"
    puts "=" * 60
    puts "🎯 Choose which squad to deploy against the #{kaiju.size} #{kaiju.creature}:"
    puts

    squads = get_squads
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. #{squad.name.upcase}"
      squad.show_squad_details(kaiju)
      puts
    end

    puts "Which squad do you want to deploy?"
    squads.each_with_index do |squad, index|
      puts "#{index + 1}. Deploy #{squad.name}"
    end
    puts "3. Cancel mission"
    print "Enter your choice (1-3): "

    choice = gets.chomp.to_i
    case choice
    when 1
      squads[0]
    when 2
      squads[1] if squads[1]
    when 3
      nil
    else
      puts "❌ Invalid choice!"
      show_squad_selection(kaiju)
    end
  end

  private

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

  def serialize_squad(squad)
    return nil unless squad

    {
      name: squad.name,
      soldiers: squad.soldiers.map do |soldier|
        {
          name: soldier.name,
          offense: soldier.offense,
          defense: soldier.defense,
          grit: soldier.grit,
          leadership: soldier.leadership,
          status: soldier.status,
          success: soldier.success
        }
      end
    }
  end

  def deserialize_squad(squad_data)
    return nil unless squad_data

    # Create empty squad
    squad = Squad.new(squad_data['name'], 0)

    # Recreate soldiers
    squad_data['soldiers'].each do |soldier_data|
      soldier = Soldier.new(
        nil,                         # name will be generated but we'll override it
        soldier_data['offense'],
        soldier_data['defense'],
        soldier_data['grit'],
        soldier_data['leadership']
      )

      # Override the generated name with the saved name
      soldier.name = soldier_data['name']
      soldier.status = soldier_data['status'].to_sym
      soldier.success = soldier_data['success']

      squad.soldiers << soldier
    end

    squad
  end
end
