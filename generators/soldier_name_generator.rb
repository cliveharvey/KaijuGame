#!/usr/bin/env ruby

class SoldierNameGenerator
  # First names from various cultures for diversity
  FIRST_NAMES = {
    western: %w[Alex Blake Casey Dana Ellis Finley Harper Jordan Kelly Logan
                Morgan Parker Quinn Riley Sage Taylor Val Wesley],
    japanese: %w[Akira Hayato Hiroshi Kenji Masato Rei Saki Takeshi Yuki Zen
                 Amara Chiyo Emi Hana Kayo Mika Nori Risa Yuka],
    slavic: %w[Anton Boris Dmitri Igor Mikhail Nikolai Pavel Viktor Alexei
               Anya Katya Nadya Olga Sasha Vera Yelena Zoya],
    arabic: %w[Ahmed Hassan Khalil Omar Rashid Samir Tariq Yusuf Zain
               Amira Fatima Layla Nadia Rania Yasmin Zara],
    african: %w[Asante Jelani Kwame Malik Sekou Tau Zuberi
                Amara Asha Kesi Nia Safiya Zara]
  }.freeze

  # Last names with military/tactical feel
  TACTICAL_SURNAMES = %w[
    Stone Steel Iron Cross Sharp Blade Wolf Fox Hawk Eagle Raven
    Storm Thunder Lightning Strike Frost Winter Snow Ice Fire Ember
    Hunter Archer Sniper Scout Ranger Guard Shield Armor Fortress
    Knight Marshal Colonel Major Captain Sergeant Corporal
  ].freeze

  # Regional surnames for authenticity
  REGIONAL_SURNAMES = {
    western: %w[Anderson Brooks Carter Davis Evans Ford Garcia Harris
                Johnson Klein Lewis Morgan Nelson Parker Roberts Smith
                Thompson Wilson Young],
    japanese: %w[Tanaka Suzuki Takahashi Watanabe Ito Yamamoto Nakamura
                 Kobayashi Kato Yoshida Yamada Sasaki Yamaguchi],
    slavic: %w[Petrov Ivanov Smirnov Kuznetsov Popov Volkov Sokolov
               Mikhailov Fedorov Morozov Volkov Kazakov],
    arabic: %w[Rahman Hassan Ali Ahmed Mohamed Ibrahim Mahmoud Omar
               Abdullah Khalil],
    african: %w[Okafor Adebayo Olumide Chukwu Eze Okoro Nwankwo
                Obiora Ogbonna Emeka]
  }.freeze

  # Nicknames and callsigns
  NICKNAMES = %w[
    Ace Blade Bullet Dash Echo Frost Ghost Hunter Ice Jagger
    Knife Lightning Phantom Ranger Shadow Steel Storm Thunder
    Viper Wolf Wraith Zero Falcon Hawk Raven Cobra Venom
    Tank Rocket Flash Blitz Crash Spike Saber Laser Turbo
    Nova Drift Pulse Shock Bolt Rage Beast Titan Reaper
  ].freeze

  # Military backgrounds
  BACKGROUNDS = [
    "Navy SEAL", "Marine Raider", "Army Ranger", "Air Force Pararescue",
    "Delta Force", "Special Forces", "Combat Engineer", "Field Medic",
    "Sniper", "Demolitions Expert", "Intelligence Operative", "Pilot",
    "Tank Commander", "Artillery Specialist", "Communications Officer",
    "Reconnaissance", "Urban Warfare Specialist", "Mountain Operations",
    "Desert Warfare", "Jungle Fighter", "Counter-Terrorism", "EOD Specialist"
  ].freeze

  def self.generate_name
    culture = FIRST_NAMES.keys.sample

    # Choose name style (70% normal, 20% nickname, 10% callsign only)
    style = rand

    if style < 0.7
      # Normal name: First Last
      first = FIRST_NAMES[culture].sample

      # 60% regional surname, 40% tactical surname
      if rand < 0.6
        last = REGIONAL_SURNAMES[culture].sample
      else
        last = TACTICAL_SURNAMES.sample
      end

      name = "#{first} #{last}"

      # 30% chance of nickname
      if rand < 0.3
        nickname = NICKNAMES.sample
        name = "#{first} \"#{nickname}\" #{last}"
      end

    elsif style < 0.9
      # Nickname as main name
      nickname = NICKNAMES.sample
      last = (rand < 0.5 ? TACTICAL_SURNAMES.sample : REGIONAL_SURNAMES[culture].sample)
      name = "#{nickname} #{last}"

    else
      # Callsign only
      name = NICKNAMES.sample
    end

    name
  end

  def self.generate_recruit_name
    # Recruits get more basic names with clear backgrounds
    culture = FIRST_NAMES.keys.sample
    first = FIRST_NAMES[culture].sample
    last = REGIONAL_SURNAMES[culture].sample
    background = BACKGROUNDS.sample

    "#{first} #{last} (#{background})"
  end

  def self.generate_veteran_name(base_name)
    # Veterans might earn nicknames or callsigns
    return base_name if base_name.include?('"') || NICKNAMES.include?(base_name.split.first)

    if rand < 0.4  # 40% chance to earn a nickname
      nickname = NICKNAMES.sample
      parts = base_name.split
      if parts.length >= 2
        "#{parts[0]} \"#{nickname}\" #{parts[1..-1].join(' ')}"
      else
        "#{base_name} \"#{nickname}\""
      end
    else
      base_name
    end
  end
end
