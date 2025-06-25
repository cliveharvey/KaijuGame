#!/usr/bin/env ruby

class SquadNameGenerator
  # Military unit designations
  UNIT_TYPES = [
    "Squadron", "Battalion", "Company", "Platoon", "Division", "Regiment",
    "Brigade", "Corps", "Unit", "Force", "Strike Team", "Task Force"
  ].freeze

  # Animal/creature names for military units
  ANIMAL_NAMES = [
    "Wolf", "Eagle", "Hawk", "Raven", "Tiger", "Lion", "Bear", "Viper",
    "Cobra", "Falcon", "Panther", "Jaguar", "Shark", "Phoenix", "Dragon",
    "Griffin", "Scorpion", "Spider", "Wolverine", "Rhino", "Buffalo", "Stallion"
  ].freeze

  # Mythological/legendary names
  MYTHIC_NAMES = [
    "Valkyrie", "Spartan", "Titan", "Atlas", "Hercules", "Achilles", "Thor",
    "Odin", "Zeus", "Apollo", "Ares", "Artemis", "Athena", "Hades", "Poseidon",
    "Fenrir", "Mjolnir", "Excalibur", "Ragnarok", "Valhalla", "Olympus"
  ].freeze

  # Weather/natural phenomena
  WEATHER_NAMES = [
    "Storm", "Thunder", "Lightning", "Tempest", "Hurricane", "Cyclone",
    "Blizzard", "Avalanche", "Earthquake", "Tsunami", "Wildfire", "Inferno",
    "Frost", "Ice", "Steel", "Iron", "Stone", "Granite", "Diamond", "Obsidian"
  ].freeze

  # Action/combat words
  ACTION_NAMES = [
    "Strike", "Assault", "Charge", "Blitz", "Raid", "Siege", "Storm",
    "Breach", "Crush", "Shatter", "Demolish", "Annihilate", "Devastate",
    "Obliterate", "Eliminate", "Terminate", "Execute", "Dominate", "Conquer"
  ].freeze

  # Color/appearance modifiers
  COLORS = [
    "Black", "Red", "Blue", "Gold", "Silver", "Steel", "Iron", "Crimson",
    "Scarlet", "Azure", "Emerald", "Platinum", "Bronze", "Copper", "Jade",
    "Obsidian", "Ivory", "Onyx", "Ruby", "Sapphire", "Diamond"
  ].freeze

  # Numerical designations
  NUMBERS = [
    "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth",
    "Ninth", "Tenth", "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta",
    "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron",
    "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"
  ].freeze

  def self.generate_squad_name
    style = rand

    if style < 0.3
      generate_animal_squad
    elsif style < 0.5
      generate_mythic_squad
    elsif style < 0.7
      generate_weather_squad
    else
      generate_action_squad
    end
  end

  private

  def self.generate_animal_squad
    animal = ANIMAL_NAMES.sample
    unit = UNIT_TYPES.sample

    if rand < 0.4
      # Add color modifier
      color = COLORS.sample
      "#{color} #{animal} #{unit}"
    elsif rand < 0.6
      # Add number
      number = NUMBERS.sample
      "#{number} #{animal} #{unit}"
    else
      # Simple animal unit
      "#{animal} #{unit}"
    end
  end

  def self.generate_mythic_squad
    mythic = MYTHIC_NAMES.sample
    unit = UNIT_TYPES.sample

    if rand < 0.3
      number = NUMBERS.sample
      "#{number} #{mythic} #{unit}"
    else
      "#{mythic} #{unit}"
    end
  end

  def self.generate_weather_squad
    weather = WEATHER_NAMES.sample
    unit = UNIT_TYPES.sample

    if rand < 0.4
      number = NUMBERS.sample
      "#{number} #{weather} #{unit}"
    else
      "#{weather} #{unit}"
    end
  end

  def self.generate_action_squad
    action = ACTION_NAMES.sample
    unit = UNIT_TYPES.sample

    if rand < 0.5
      # Action + animal/mythic
      modifier = (ANIMAL_NAMES + MYTHIC_NAMES).sample
      "#{action} #{modifier} #{unit}"
    elsif rand < 0.7
      # Number + action
      number = NUMBERS.sample
      "#{number} #{action} #{unit}"
    else
      # Simple action unit
      "#{action} #{unit}"
    end
  end

  def self.generate_pair_of_squad_names
    # Generate two different squads ensuring they don't have the same name
    first_squad = generate_squad_name
    second_squad = generate_squad_name

    # Ensure they're different (try up to 5 times)
    attempts = 0
    while first_squad == second_squad && attempts < 5
      second_squad = generate_squad_name
      attempts += 1
    end

    [first_squad, second_squad]
  end
end
