#!/usr/bin/env ruby

class RichKaijuGenerator
  # Monster syllables that sound more menacing
  DARK_SYLLABLES = %w[
    Mor Grim Drak Skor Vex Zar Krag Thul Vor Bane Mal Nox
    Ghol Rak Tor Hex Neth Shar Vak Kol Gul Zon Hroth Ulm
  ].freeze

  PRIME_SYLLABLES = %w[
    goth rak mor zul thon kar vex dun skal thor bex nul
    grim dark void doom rage wrath fury blood bone iron
  ].freeze

  ENDING_SYLLABLES = %w[
    us on ar eth ul oth ek ak ox ix yr um en is oth
    destroyer terror bane scourge render slayer reaper
  ].freeze

  # Cosmic/Eldritch inspired names
  COSMIC_PREFIXES = %w[
    Azath Yog Cthul Nyarl Shub Tsath Hast Dagon Morg Zoth
    Ubbo Atlach Glaaki Ithaq Mnomq Rlyeh Sarnath Kadath
  ].freeze

  COSMIC_SUFFIXES = [
    'oggua', 'hotep', 'sothoth', 'tlahuizcalpantecuhtli', 'niggurath',
    'nafl', 'thagn', "ph'nglui", "mglw'nafh", 'fhtagn', "ia'ia", 'shoggoth'
  ].freeze

  # Elemental/Nature based
  ELEMENTAL_ROOTS = %w[
    Ignis Aqua Terra Ventus Fulgor Glacies Umbra Lux
    Pyro Hydro Geo Aero Electro Cryo Necro Photo
  ].freeze

  NATURE_ASPECTS = %w[
    Storm Flame Frost Quake Tide Thunder Lightning Gale
    Magma Blizzard Tremor Tsunami Tornado Hurricane Avalanche
  ].freeze

  # Ancient/Mythological
  ANCIENT_PREFIXES = %w[
    Baal Moloch Astor Dagon Belial Abaddon Malphas Bael
    Astaroth Beelzebub Mammon Azazel Beleth Paimon Sitri
  ].freeze

  MYTHIC_TITLES = [
    "the Ancient One", "the Destroyer", "the Devourer", "the Terrible",
    "the Unstoppable", "the Nightmare", "the Silent Death", "the Void Walker",
    "the World Ender", "the Chaos Bringer", "the Shadow That Consumes",
    "the Last Horror", "the Eternal Hunger", "Scourge of Cities",
    "The Unmaking", "Herald of Ruin", "Bane of Mortals", "The Writhing Dark"
  ].freeze

  # Japanese-inspired kaiju names
  JAPANESE_ELEMENTS = %w[
    Goji Ryu Kaiju Mecha Oni Yokai Tengu Kappa Baku
    Kitsune Nue Raiju Shisa Qilin Suzaku Genbu Byakko
  ].freeze

  def self.generate_rich_names
    style = rand

    if style < 0.25
      generate_syllabic_names
    elsif style < 0.5
      generate_cosmic_names
    elsif style < 0.75
      generate_elemental_names
    else
      generate_ancient_names
    end
  end

  private

  def self.generate_syllabic_names
    # Multi-syllable monster names
    syllable_count = rand(2..4)

    monster_parts = []
    syllable_count.times do
      if rand < 0.4
        monster_parts << DARK_SYLLABLES.sample
      else
        monster_parts << PRIME_SYLLABLES.sample
      end
    end

    # Maybe add ending
    if rand < 0.6
      monster_parts << ENDING_SYLLABLES.sample
    end

    monster_name = monster_parts.join.capitalize

    # Create English version based on meaning
    english_base = generate_english_descriptor
    if rand < 0.7
      english_name = "#{english_base} #{MYTHIC_TITLES.sample}"
    else
      english_name = english_base
    end

    [english_name, monster_name]
  end

  def self.generate_cosmic_names
    # Lovecraftian inspired
    prefix = COSMIC_PREFIXES.sample
    suffix = COSMIC_SUFFIXES.sample

    monster_name = "#{prefix}-#{suffix}"
    english_name = "#{generate_cosmic_descriptor} #{MYTHIC_TITLES.sample}"

    [english_name, monster_name]
  end

  def self.generate_elemental_names
    # Nature/elemental themed
    element = ELEMENTAL_ROOTS.sample
    aspect = NATURE_ASPECTS.sample

    monster_name = "#{element}#{rand < 0.5 ? aspect.downcase : ''}"
    english_name = "#{aspect} #{generate_elemental_descriptor}"

    if rand < 0.6
      english_name += " #{MYTHIC_TITLES.sample}"
    end

    [english_name, monster_name]
  end

  def self.generate_ancient_names
    # Ancient/mythological
    base = ANCIENT_PREFIXES.sample
    ending = ENDING_SYLLABLES.sample

    monster_name = "#{base}#{ending}"
    english_name = "#{generate_ancient_descriptor} #{MYTHIC_TITLES.sample}"

    [english_name, monster_name]
  end

  def self.generate_english_descriptor
    descriptors = [
      "Crimson", "Shadow", "Void", "Iron", "Bone", "Blood", "Dark",
      "Nightmare", "Terror", "Death", "Doom", "Chaos", "Rage", "Fury",
      "Silent", "Howling", "Writhing", "Consuming", "Eternal", "Ancient"
    ]
    descriptors.sample
  end

  def self.generate_cosmic_descriptor
    descriptors = [
      "The Whispered", "The Unseen", "The Forgotten", "The Crawling",
      "The Dreaming", "The Lurking", "The Watching", "The Waiting",
      "The Hungering", "The Endless", "The Nameless", "The Formless"
    ]
    descriptors.sample
  end

  def self.generate_elemental_descriptor
    descriptors = [
      "Incarnate", "Manifest", "Embodied", "Born", "Risen", "Awakened",
      "Unleashed", "Summoned", "Conjured", "Invoked", "Called Forth"
    ]
    descriptors.sample
  end

  def self.generate_ancient_descriptor
    descriptors = [
      "The Primordial", "The First", "The Elder", "The Archaic",
      "The Timeless", "The Ageless", "The Immemorial", "The Progenitor",
      "The Forefather", "The Original", "The Prime", "The Genesis"
    ]
    descriptors.sample
  end
end
