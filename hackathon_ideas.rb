# 🚀 HACKATHON QUICK WINS
# Copy these into your main game for instant features!

# 1. WEAPON LOADOUTS (5 minutes)
class Squad
  WEAPON_TYPES = {
    rifles: { damage_bonus: 5, name: "Assault Rifles" },
    rockets: { damage_bonus: 15, name: "Rocket Launchers" },
    lasers: { damage_bonus: 10, name: "Laser Cannons" }
  }.freeze

  attr_reader :weapon_type

  def initialize(name = "Boom Boom Shoe Makers", soldier_count = 5, weapon = :rifles)
    @weapon_type = weapon
    @soldiers = soldier_count.times.map { Soldier.new }
    # Apply weapon bonus to all soldiers
    @soldiers.each { |s| s.skill += WEAPON_TYPES[weapon][:damage_bonus] }
  end
end

# 2. KAIJU SPECIAL ABILITIES (10 minutes)
class Kaiju
  SPECIAL_ABILITIES = [
    { name: "Regeneration", effect: -10 },  # Makes kaiju harder
    { name: "Berserker Rage", effect: -15 },
    { name: "Psychic Shield", effect: -5 },
    { name: "Toxic Breath", effect: -12 }
  ].freeze

  def initialize
    # ... existing code ...
    @special_ability = SPECIAL_ABILITIES.sample
    @difficulty += @special_ability[:effect].abs  # Make it harder
  end

  def ability_description
    "⚠️  SPECIAL: #{@special_ability[:name]} (Threat +#{@special_ability[:effect].abs})"
  end
end

# 3. BASE UPGRADES SYSTEM (15 minutes)
class Base
  attr_reader :upgrades, :funds

  def initialize
    @funds = 1000
    @upgrades = {
      training_facility: 0,  # Improves soldier skill
      medical_bay: 0,        # Reduces casualties
      weapons_lab: 0         # Better equipment
    }
  end

  def upgrade_cost(type)
    (@upgrades[type] + 1) * 500
  end

  def can_upgrade?(type)
    @funds >= upgrade_cost(type)
  end

  def purchase_upgrade(type)
    return false unless can_upgrade?(type)
    @funds -= upgrade_cost(type)
    @upgrades[type] += 1
    true
  end

  def apply_bonuses(squad)
    # Training bonus
    squad.soldiers.each { |s| s.skill += @upgrades[:training_facility] * 3 }

    # Medical bay reduces severe injuries
    # Weapons lab could add damage bonuses
  end
end

# 4. STORY MODE WITH PROGRESSION (20 minutes)
class Campaign
  STORY_MISSIONS = [
    {
      title: "First Contact",
      description: "A small kaiju emerges from the ocean...",
      max_difficulty: 20,
      reward: 500
    },
    {
      title: "The Awakening",
      description: "Multiple kaiju sightings reported worldwide...",
      max_difficulty: 40,
      reward: 800
    },
    {
      title: "Final Assault",
      description: "The Kaiju King rises from the depths!",
      max_difficulty: 60,
      reward: 1500
    }
  ].freeze

  attr_reader :current_mission, :completed_missions

  def initialize
    @current_mission = 0
    @completed_missions = []
  end

  def current_mission_data
    STORY_MISSIONS[@current_mission]
  end

  def complete_mission(success)
    mission = current_mission_data
    @completed_missions << { mission: mission, success: success }
    @current_mission += 1 if success && @current_mission < STORY_MISSIONS.length - 1
  end

  def campaign_complete?
    @current_mission >= STORY_MISSIONS.length
  end
end

# 5. ADVANCED BATTLE SYSTEM (25 minutes)
class BattleSystem
  def self.detailed_combat(squad, kaiju)
    battle_log = []

    # Phase 1: Approach
    battle_log << "🌊 The squad approaches the kaiju through the destroyed city..."

    # Phase 2: Individual soldier actions
    squad.soldiers.each_with_index do |soldier, i|
      action = %w[flanking_maneuver direct_assault covering_fire tactical_retreat].sample

      case action
      when "flanking_maneuver"
        battle_log << "🏃 #{soldier.name} attempts a flanking maneuver..."
        success_chance = soldier.skill + 10
      when "direct_assault"
        battle_log << "⚔️  #{soldier.name} charges directly at the kaiju!"
        success_chance = soldier.skill - 5
      when "covering_fire"
        battle_log << "🔫 #{soldier.name} provides covering fire for the team..."
        success_chance = soldier.skill + 5
      end

      if rand(100) < success_chance
        battle_log << "   ✅ Success! The maneuver works perfectly."
        soldier.success = true
      else
        battle_log << "   ❌ The kaiju counters the attack!"
        soldier.combat(kaiju.difficulty)
      end
    end

    # Phase 3: Final outcome
    if squad.soldiers.count(&:success) >= 3
      battle_log << "\n🎊 The coordinated assault overwhelms the kaiju!"
      battle_log << "🏆 VICTORY!"
    else
      battle_log << "\n💥 The kaiju's rampage continues..."
      battle_log << "😞 DEFEAT..."
    end

    battle_log
  end
end

# 6. SIMPLE SAVE SYSTEM (10 minutes)
require 'json'

class SaveGame
  SAVE_FILE = 'kaiju_save.json'

  def self.save(base, campaign)
    data = {
      base: base.to_h,
      campaign: campaign.to_h,
      timestamp: Time.now.to_i
    }
    File.write(SAVE_FILE, JSON.pretty_generate(data))
  end

  def self.load
    return nil unless File.exist?(SAVE_FILE)
    data = JSON.parse(File.read(SAVE_FILE))
    # Convert back to objects...
    data
  end
end

puts "🚀 Copy any of these features into kaiju_game.rb for instant upgrades!"
puts "💡 Each feature is designed for <30 minute implementation"
puts "🎯 Mix and match based on your hackathon theme!"
