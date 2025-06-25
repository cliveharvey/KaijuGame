class RichKaijuGenerator
  # Simplified version of the massive name arrays from the original
  ADJECTIVES = [
    ["ace", "alak"], ["ancient", "zustash"], ["angry", "ustos"], ["armored", "tosid"],
    ["ashen", "ibruk"], ["bad", "asdos"], ["big", "etag"], ["black", "udir"],
    ["blind", "nural"], ["bloody", "nashon"], ["blue", "enor"], ["bold", "murak"],
    ["bright", "shin"], ["cold", "nekik"], ["crazed", "uling"], ["dark", "umom"],
    ["dead", "nokor"], ["deep", "thol"], ["doomed", "okbod"], ["elder", "okir"],
    ["eternal", "zilir"], ["evil", "gedor"], ["fierce", "mokul"], ["giant", "thagar"],
    ["golden", "shinul"], ["great", "magul"], ["hidden", "nureth"], ["iron", "ferak"],
    ["mighty", "gorath"], ["silent", "whisul"], ["stone", "roketh"], ["swift", "velak"],
    ["terrible", "drakul"], ["wild", "ferak"], ["wise", "sageth"], ["young", "neweth"]
  ].freeze

  THE_XS = [
    ["destroyer", "mokthul"], ["terror", "draketh"], ["shadow", "umbrak"],
    ["flame", "pyrak"], ["storm", "tempek"], ["void", "nullak"], ["death", "mortis"],
    ["fury", "rageth"], ["nightmare", "dreamak"], ["chaos", "voidul"],
    ["vengeance", "retrak"], ["doom", "fatalis"], ["blade", "gladek"],
    ["fang", "dentul"], ["claw", "unguis"], ["wing", "alatuk"], ["eye", "oculak"],
    ["heart", "cordis"], ["soul", "animak"], ["mind", "mentis"], ["bone", "ossek"],
    ["blood", "sangek"], ["fire", "ignisul"], ["ice", "glacek"], ["lightning", "fulgur"]
  ].freeze

  def self.generate_rich_names
    english_parts = []
    monster_parts = []

    # First name part
    first = ADJECTIVES.sample
    english_parts << first[0].capitalize
    monster_parts << first[1].capitalize

    # Compound parts
    compound1 = ADJECTIVES.sample
    compound2 = ADJECTIVES.sample

    english_parts << compound1[0]
    english_parts << compound2[0]
    monster_parts << compound1[1]
    monster_parts << compound2[1]

    # Maybe add epithet
    if rand < 0.6
      epithet = THE_XS.sample
      english_name = english_parts.join(" ") + " the " + epithet[0].capitalize
      monster_name = monster_parts.join("") + " " + epithet[1].capitalize
    else
      english_name = english_parts.join(" ")
      monster_name = monster_parts.join("")
    end

    [english_name, monster_name]
  end
end
