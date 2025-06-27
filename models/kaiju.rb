require_relative '../generators/kaiju_generator'

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
    appearance: ['putrid stinky odour', 'compound eyes', 'eye stalks', 'thick fur', 'slime oozing off its body'],
    movement: ['it\'s skin a blur, making it hard to make out', 'lightning fast reflexes', 'earth shaking steps'],
    special: ['no visible eyes to speak of', 'a cluster of eyes defining its face', 'reflective surface']
  }.freeze

  WEAPONS = {
    melee: ['razor sharp claws', 'bone crushing jaws', 'whip-like tail', 'massive fists'],
    ranged: ['acid spit', 'lightning breath', 'sonic roar', 'explosive spores'],
    psychic: ['mind blast', 'fear aura', 'confusion waves', 'nightmare projection']
  }.freeze

  attr_reader :name_english, :name_monster, :size, :creature, :material,
              :characteristic, :weapon, :difficulty, :offense, :defense, :speed, :special

  def initialize(squads = nil)
    # Simple natural generation - no artificial scaling
    generate_natural_kaiju

    # Use the rich name generator
    @name_english, @name_monster = RichKaijuGenerator.generate_rich_names
  end

  def stat_summary
    "ATK:#{@offense} DEF:#{@defense} SPD:#{@speed} SPC:#{@special}"
  end

  def trait_summary
    "#{@size.capitalize} #{@creature} with #{@material} skin, #{@characteristic}, armed with #{@weapon}"
  end

  def detailed_trait_description
    description = []
    description << "🦖 **PHYSICAL FORM**: #{@size.capitalize} #{@creature}"
    description << "🛡️  **SKIN/ARMOR**: #{@material.capitalize} composition"
    description << "👁️  **NOTABLE FEATURES**: #{@characteristic.capitalize}"
    description << "⚔️  **PRIMARY WEAPON**: #{@weapon.capitalize}"
    description << "🎯 **COMBAT TRAITS**: #{combat_style_description}"
    description
  end

  def combat_style_description
    # Determine combat style based on stats
    if @offense > @defense && @offense > @speed
      if @weapon.include?('claw') || @weapon.include?('jaw') || @weapon.include?('fist')
        "Aggressive melee combatant"
      else
        "Heavy assault specialist"
      end
    elsif @defense > @offense && @defense > @speed
      "Defensive tank - tough to bring down"
    elsif @speed > @offense && @speed > @defense
      "Hit-and-run tactics - strikes fast"
    elsif @special > 25
      "Supernatural abilities - unpredictable"
    else
      "Balanced fighter - adaptable to situations"
    end
  end

  def show_detailed_stats
    puts "📊 KAIJU COMBAT ANALYSIS:"
    puts "   Offensive Power: #{@offense} #{offense_description}"
    puts "   Defensive Rating: #{@defense} #{defense_description}"
    puts "   Speed Factor: #{@speed} #{speed_description}"
    puts "   Special Ability: #{@special} #{special_description}"
    puts "   Overall Threat: #{@difficulty}"
    puts
    puts "🔍 DETAILED TRAITS:"
    detailed_trait_description.each { |trait| puts "   #{trait}" }
  end

  def show_full_trait_profile
    puts "=" * 60
    puts "🦖 KAIJU TRAIT PROFILE: #{@name_english}"
    puts "=" * 60
    puts "📛 Designation: #{@name_monster}"
    puts
    puts "🏗️  PHYSICAL CHARACTERISTICS:"
    puts "   Size Classification: #{@size.capitalize} (#{get_size_description})"
    puts "   Base Creature Type: #{@creature.capitalize}"
    puts "   Skin/Armor Composition: #{get_material_description}"
    puts "   Distinctive Features: #{@characteristic.capitalize}"
    puts
    puts "⚔️  COMBAT CAPABILITIES:"
    puts "   Primary Weapon System: #{get_weapon_description}"
    puts "   Combat Style: #{combat_style_description}"
    puts "   Threat Assessment: #{get_threat_assessment}"
    puts
    puts "📊 STATISTICAL BREAKDOWN:"
    puts "   ATK: #{@offense}/50 (#{offense_description})"
    puts "   DEF: #{@defense}/50 (#{defense_description})"
    puts "   SPD: #{@speed}/50 (#{speed_description})"
    puts "   SPC: #{@special}/50 (#{special_description})"
    puts "   Overall Difficulty: #{@difficulty}"
    puts "=" * 60
  end

  private

  def generate_natural_kaiju
    # Random selection of attributes
    @size = SIZES.sample
    @creature = CREATURES.sample
    @material = MATERIALS.values.flatten.sample
    @characteristic = CHARACTERISTICS.values.flatten.sample
    @weapon = WEAPONS.values.flatten.sample

    # Generate stats naturally from attributes
    generate_base_stats_from_size
    apply_creature_modifiers
    apply_material_modifiers
    apply_characteristic_modifiers
    apply_weapon_modifiers
    calculate_difficulty
  end

  def generate_base_stats_from_size
    # Base stats from size - reasonable ranges
    case @size
    when :small
      @offense = rand(8..15)
      @defense = rand(6..12)
      @speed = rand(12..20)
      @special = rand(8..15)
    when :medium
      @offense = rand(12..20)
      @defense = rand(10..18)
      @speed = rand(10..18)
      @special = rand(10..18)
    when :large
      @offense = rand(18..28)
      @defense = rand(15..25)
      @speed = rand(8..15)
      @special = rand(12..22)
    when :huge
      @offense = rand(25..35)
      @defense = rand(20..30)
      @speed = rand(6..12)
      @special = rand(15..25)
    when :massive
      @offense = rand(30..40)
      @defense = rand(25..35)
      @speed = rand(4..10)
      @special = rand(18..28)
    when :gigantic
      @offense = rand(35..45)
      @defense = rand(30..40)
      @speed = rand(2..8)
      @special = rand(20..30)
    end
  end

  def apply_creature_modifiers
    case @creature
    # Fast predators
    when 'allosaurus', 'deinonychus', 'hawk', 'eagle', 'tiger', 'snake', 'spider'
      @speed += rand(3..8)
      @offense += rand(2..6)
      @defense -= rand(1..3)
    # Defensive creatures
    when 'brontosaurus', 'elephant', 'bear', 'boar', 'ox'
      @defense += rand(4..10)
      @offense += rand(1..4)
      @speed -= rand(2..5)
    # Magical/special creatures
    when 'dragon', 'hydra', 'minotaur'
      @special += rand(4..8)
      @offense += rand(2..5)
    # Weird creatures
    when 'fungus', 'ooze', 'squid'
      @special += rand(5..10)
      @defense += rand(2..6)
      @speed -= rand(1..4)
    end
  end

  def apply_material_modifiers
    material_type = MATERIALS.find { |type, materials| materials.include?(@material) }&.first

    case material_type
    when :metal
      case @material
      when 'titanium'
        @defense += rand(8..15)
        @offense += rand(2..5)
      when 'steel', 'iron'
        @defense += rand(5..10)
        @offense += rand(1..4)
      when 'bronze', 'copper'
        @defense += rand(3..7)
        @offense += rand(1..3)
      else
        @defense += rand(2..5)
      end
    when :rock
      @defense += rand(3..8)
      @speed -= rand(1..3)
    when :gem
      @special += rand(4..10)
      case @material
      when 'diamond'
        @defense += rand(3..6)
      when 'obsidian'
        @offense += rand(3..6)
      end
    when :other
      case @material
      when 'glass'
        @offense += rand(4..8)
        @defense -= rand(2..4)
      when 'ice'
        @speed += rand(2..5)
        @special += rand(2..5)
      when 'wood'
        @speed += rand(1..4)
      end
    end
  end

  def apply_characteristic_modifiers
    case @characteristic
    when 'lightning fast reflexes'
      @speed += rand(4..8)
    when 'earth shaking steps'
      @offense += rand(3..6)
      @speed -= rand(1..3)
    when 'it\'s skin a blur, making it hard to make out'
      @speed += rand(3..6)
      @defense += rand(2..4)
    when 'compound eyes', 'a cluster of eyes defining its face'
      @special += rand(3..6)
    when 'reflective surface'
      @defense += rand(2..5)
      @special += rand(2..5)
    when 'slime oozing off its body'
      @special += rand(4..7)
      @defense += rand(1..3)
    end
  end

  def apply_weapon_modifiers
    weapon_type = WEAPONS.find { |type, weapons| weapons.include?(@weapon) }&.first

    case weapon_type
    when :melee
      case @weapon
      when 'razor sharp claws'
        @offense += rand(4..8)
      when 'bone crushing jaws'
        @offense += rand(5..10)
      when 'whip-like tail'
        @offense += rand(3..6)
        @speed += rand(1..3)
      when 'massive fists'
        @offense += rand(6..12)
        @speed -= rand(1..2)
      end
    when :ranged
      @offense += rand(3..7)
      @special += rand(2..5)
    when :psychic
      @special += rand(5..12)
      @offense += rand(1..3)
    end
  end

  def calculate_difficulty
    # Simple difficulty calculation
    @difficulty = (@offense * 0.4 + @defense * 0.3 + @speed * 0.2 + @special * 0.3).round

    # Ensure reasonable bounds
    @offense = [@offense, 5].max
    @defense = [@defense, 3].max
    @speed = [@speed, 1].max
    @special = [@special, 3].max
  end

  def offense_description
    case @offense
    when 0..15 then "Weak"
    when 16..25 then "Moderate"
    when 26..35 then "Strong"
    when 36..45 then "Devastating"
    else "Apocalyptic"
    end
  end

  def defense_description
    case @defense
    when 0..12 then "Fragile"
    when 13..22 then "Armored"
    when 23..32 then "Heavily Armored"
    when 33..42 then "Nearly Invulnerable"
    else "Impenetrable"
    end
  end

  def speed_description
    case @speed
    when 0..8 then "Sluggish"
    when 9..16 then "Average Speed"
    when 17..24 then "Fast"
    when 25..32 then "Lightning Fast"
    else "Teleportation Speed"
    end
  end

  def special_description
    case @special
    when 0..12 then "Mundane"
    when 13..20 then "Unusual"
    when 21..28 then "Supernatural"
    when 29..36 then "Reality-Bending"
    else "Cosmic Horror"
    end
  end

  def get_size_description
    case @size
    when :small then "Building-sized, highly mobile"
    when :medium then "City block scale, balanced threat"
    when :large then "Multiple city blocks, major threat"
    when :huge then "District-wide destruction potential"
    when :massive then "City-wide catastrophic threat"
    when :gigantic then "Regional disaster, maximum threat level"
    end
  end

  def get_material_description
    material_type = MATERIALS.find { |type, materials| materials.include?(@material) }&.first
    case material_type
    when :flesh
      "#{@material.capitalize} organic tissue with natural defensive properties"
    when :rock
      "#{@material.capitalize} stone composition providing excellent protection"
    when :gem
      "#{@material.capitalize} crystalline structure with unique properties"
    when :metal
      "#{@material.capitalize} metallic plating offering superior defense"
    when :other
      "#{@material.capitalize} exotic material with unusual characteristics"
    else
      "#{@material.capitalize} composition of unknown origin"
    end
  end

  def get_weapon_description
    weapon_type = WEAPONS.find { |type, weapons| weapons.include?(@weapon) }&.first
    description = @weapon.capitalize
    case weapon_type
    when :melee
      "#{description} - Close combat specialization"
    when :ranged
      "#{description} - Long-range attack capability"
    when :psychic
      "#{description} - Mental/supernatural assault weapon"
    else
      description
    end
  end

  def get_threat_assessment
    case @difficulty
    when 0..20 then "Manageable - Standard deployment recommended"
    when 21..35 then "Serious - Enhanced tactical preparation required"
    when 36..50 then "Extreme - Elite forces and specialized equipment needed"
    when 51..65 then "Critical - Maximum force deployment essential"
    else "Apocalyptic - Consider evacuation protocols"
    end
  end
end
