class BattleText
  def initialize
    # Skill-based movement descriptions
    @high_offense_movement = [
      "aggressively advanced on the kaiju's flanks",
      "charged forward with weapons ready",
      "moved in for a devastating assault",
      "positioned for maximum firepower",
      "led the attack from the front lines"
    ]

    @high_defense_movement = [
      "took strategic defensive positions",
      "secured cover while maintaining sight lines",
      "established a fortified position",
      "moved to protect vulnerable squad members",
      "created a defensive perimeter"
    ]

    @high_grit_movement = [
      "pressed forward despite the overwhelming danger",
      "refused to retreat even as debris rained down",
      "maintained position under intense pressure",
      "stood firm against the kaiju's intimidating presence",
      "pushed through fear and exhaustion"
    ]

    @high_leadership_movement = [
      "coordinated the squad's tactical approach",
      "directed teammates into optimal positions",
      "rallied the squad with decisive commands",
      "orchestrated a synchronized advance",
      "maintained squad cohesion under fire"
    ]

    # Skill-based combat actions
    @high_offense_actions = [
      "unleashed a devastating barrage of firepower",
      "targeted critical weak points with precision",
      "delivered crushing blows to vital areas",
      "overwhelmed the kaiju with aggressive tactics",
      "exploited openings with lethal efficiency"
    ]

    @high_defense_actions = [
      "expertly deflected the kaiju's attacks",
      "used superior positioning to avoid damage",
      "protected civilians with defensive maneuvers",
      "absorbed the kaiju's assault while maintaining position",
      "turned the kaiju's strength against itself"
    ]

    @high_grit_actions = [
      "fought through pain and exhaustion",
      "refused to give ground despite overwhelming odds",
      "maintained focus despite the chaos around them",
      "pushed beyond normal human limits",
      "stood defiant in the face of certain death"
    ]

    @high_leadership_actions = [
      "inspired the squad to fight harder than ever",
      "coordinated a brilliant tactical maneuver",
      "directed concentrated fire on weak points",
      "boosted team morale with fearless leadership",
      "synchronized the squad's attacks perfectly"
    ]

    # Status-specific outcomes
    @kia_descriptions = [
      "was caught in the kaiju's devastating counterattack",
      "made the ultimate sacrifice to protect civilians",
      "fell while holding the line against impossible odds",
      "was overwhelmed by the kaiju's brutal assault",
      "died a hero, buying precious time for the mission"
    ]

    @injured_descriptions = [
      "was thrown against rubble but survived",
      "took heavy damage while completing their objective",
      "suffered serious wounds but accomplished their mission",
      "was battered by debris but kept fighting",
      "endured grievous injuries in service of the mission"
    ]

    @shaken_descriptions = [
      "was rattled by the kaiju's terrifying presence",
      "felt the psychological impact of the creature's roar",
      "was momentarily stunned by the battle's intensity",
      "experienced the horror of facing such a monster",
      "was affected by the chaos but remained functional"
    ]

    # Mission success outcomes
    @success_outcomes = [
      "The kaiju reeled from the effective assault!",
      "Critical damage was dealt to the monster!",
      "The creature's advance was successfully halted!",
      "Civilians escaped thanks to the diversion!",
      "The kaiju's weak point was exposed!",
      "The squad's coordination proved devastating!"
    ]

    @failure_outcomes = [
      "The kaiju shrugged off the attack and pressed forward",
      "The monster's rampage continued unabated",
      "Buildings crumbled under the kaiju's relentless assault",
      "The creature's roar shattered windows for blocks",
      "Panic spread as the kaiju advanced unopposed",
      "The monster's power seemed limitless"
    ]
  end

  def battle_summary(soldier)
    texts = []

    # Determine soldier's dominant skill for personalized narrative
    dominant_skill = get_dominant_skill(soldier)

    # Check if soldier is weak for special narrative
    is_weak = soldier.is_weak_soldier?

    # Skill-based movement description
    movement_text = get_skill_based_text(dominant_skill, 'movement')
    if is_weak && soldier.status == :alive
      movement_text += " despite their inexperience"
    elsif is_weak && soldier.status != :alive
      movement_text += " showing incredible courage"
    end
    texts << "🎯 #{soldier.name} #{movement_text}"

    # Skill-based action description
    action_text = get_skill_based_text(dominant_skill, 'action')
    if is_weak && soldier.success
      action_text += " far beyond their expected capability"
    elsif is_weak && !soldier.success
      action_text += " but was clearly outmatched"
    end
    texts << "⚔️  #{soldier.name} #{action_text}"

    # Status-specific description
    if soldier.status == :kia
      kia_text = @kia_descriptions.sample
      if is_weak
        kia_text += " - a recruit who gave everything"
      end
      texts << "💀 #{soldier.name} #{kia_text}"
    elsif soldier.status == :injured
      injured_text = @injured_descriptions.sample
      if is_weak
        injured_text += " despite their limited training"
      end
      texts << "🩹 #{soldier.name} #{injured_text}"
    elsif soldier.status == :shaken
      shaken_text = @shaken_descriptions.sample
      if is_weak
        shaken_text += " - understandable for a less experienced soldier"
      end
      texts << "⚡ #{soldier.name} #{shaken_text}"
    end

    # Mission outcome based on success
    outcome = soldier.success ? @success_outcomes.sample : @failure_outcomes.sample
    texts << "📊 #{outcome}"

    # Add skill improvement note if soldier survived
    if soldier.status == :alive || soldier.status == :shaken
      if is_weak
        texts << "📈 #{soldier.name} gained crucial combat experience from surviving the encounter"
      else
        texts << "📈 #{soldier.name} gained valuable experience from the encounter"
      end
    end

    texts
  end

  def get_detailed_battle_intro(squad, kaiju)
    intro_texts = []

    # Squad assessment
    total_offense = squad.soldiers.sum(&:offense)
    total_defense = squad.soldiers.sum(&:defense)
    avg_leadership = squad.soldiers.sum(&:leadership) / squad.soldiers.count

    intro_texts << "🎯 Squad Assessment: #{squad.soldiers.count} soldiers ready for deployment"
    intro_texts << "⚔️  Combined Offense: #{total_offense} | Defense: #{total_defense} | Avg Leadership: #{avg_leadership}"

    # Enhanced threat analysis with traits
    intro_texts << "🚨 TARGET ANALYSIS:"
    intro_texts << "   🦖 Form: #{kaiju.size.capitalize} #{kaiju.creature}"
    intro_texts << "   🛡️  Armor: #{kaiju.material.capitalize} skin composition"
    intro_texts << "   👁️  Features: #{kaiju.characteristic}"
    intro_texts << "   ⚔️  Primary Weapon: #{kaiju.weapon}"

    # Threat level assessment
    if kaiju.difficulty <= 20
      threat_level = "manageable threat"
    elsif kaiju.difficulty <= 40
      threat_level = "serious challenge"
    elsif kaiju.difficulty <= 50
      threat_level = "extreme danger"
    else
      threat_level = "apocalyptic threat"
    end

    intro_texts << "💥 Overall Assessment: #{threat_level.upcase}"
    intro_texts << "🎯 Tactical Notes: #{get_tactical_notes_for_traits(kaiju)}"
    intro_texts << "💥 Estimated Casualty Risk: #{estimate_casualty_risk(squad, kaiju)}"

    intro_texts
  end

  def get_trait_based_combat_description(kaiju, success)
    descriptions = []

    # Weapon-specific combat descriptions
    if success
      descriptions << get_weapon_success_description(kaiju.weapon)
      descriptions << get_material_interaction_description(kaiju.material, true)
    else
      descriptions << get_weapon_failure_description(kaiju.weapon)
      descriptions << get_material_interaction_description(kaiju.material, false)
    end

    # Characteristic-based flavor text
    descriptions << get_characteristic_flavor_text(kaiju.characteristic)

    descriptions.sample
  end

  private

  def get_dominant_skill(soldier)
    skills = {
      offense: soldier.offense,
      defense: soldier.defense,
      grit: soldier.grit,
      leadership: soldier.leadership
    }
    skills.max_by { |_, value| value }.first
  end

  def get_skill_based_text(skill, type)
    case skill
    when :offense
      type == 'movement' ? @high_offense_movement.sample : @high_offense_actions.sample
    when :defense
      type == 'movement' ? @high_defense_movement.sample : @high_defense_actions.sample
    when :grit
      type == 'movement' ? @high_grit_movement.sample : @high_grit_actions.sample
    when :leadership
      type == 'movement' ? @high_leadership_movement.sample : @high_leadership_actions.sample
    end
  end

  def estimate_casualty_risk(squad, kaiju)
    avg_power = squad.soldiers.sum { |s| s.offense + s.defense + s.grit + s.leadership } / squad.soldiers.count
    threat_ratio = kaiju.difficulty.to_f / avg_power

    if threat_ratio < 0.7
      "Low"
    elsif threat_ratio < 1.2
      "Moderate"
    elsif threat_ratio < 1.8
      "High"
    else
      "Critical"
    end
  end

  def get_tactical_notes_for_traits(kaiju)
    notes = []

    # Material-based tactical advice
    case kaiju.material
    when 'titanium', 'steel', 'iron'
      notes << "Heavy armor plating will require concentrated fire"
    when 'glass'
      notes << "Brittle armor - but expect sharp fragments when hit"
    when 'ice'
      notes << "Cold-based defenses may slow our weapons"
    when 'obsidian', 'diamond'
      notes << "Crystalline armor - look for stress fractures"
    when 'leathery', 'rotting'
      notes << "Organic armor may be vulnerable to sustained damage"
    end

    # Weapon-based tactical advice
    case kaiju.weapon
    when /claw/
      notes << "Maintain distance to avoid close combat"
    when /spit|breath/
      notes << "Expect ranged attacks - stay mobile"
    when /roar|blast/
      notes << "Psychological effects possible - maintain squad cohesion"
    when /tail/
      notes << "Watch for sweeping attacks from behind"
    end

    notes.sample || "Standard engagement protocols apply"
  end

  def get_weapon_success_description(weapon)
    case weapon
    when /claw/
      "The squad successfully evaded the creature's razor-sharp claws!"
    when /jaw|teeth/
      "Quick thinking kept the soldiers clear of those bone-crushing jaws!"
    when /spit|acid/
      "The team dodged the corrosive spray with expert timing!"
    when /breath|roar/
      "Disciplined formation held despite the creature's sonic assault!"
    when /tail/
      "Soldiers scattered as the massive tail swept overhead!"
    when /fist/
      "The squad avoided the devastating ground-pound attacks!"
    else
      "The squad effectively countered the kaiju's primary weapon!"
    end
  end

  def get_weapon_failure_description(weapon)
    case weapon
    when /claw/
      "The creature's claws raked across the battlefield!"
    when /jaw|teeth/
      "Those massive jaws snapped dangerously close to the squad!"
    when /spit|acid/
      "Corrosive fluid splashed across the combat zone!"
    when /breath|roar/
      "The deafening roar disoriented the attacking forces!"
    when /tail/
      "The whip-like tail scattered soldiers like bowling pins!"
    when /fist/
      "Massive fists pounded the ground, creating shock waves!"
    else
      "The kaiju's attacks proved devastatingly effective!"
    end
  end

  def get_material_interaction_description(material, success)
    case material
    when 'titanium', 'steel'
      success ? "Armor-piercing rounds found gaps in the metal plating!" : "Weapons sparked harmlessly off the metallic hide!"
    when 'glass'
      success ? "The crystalline surface cracked under concentrated fire!" : "Shattered glass fragments created a deadly storm!"
    when 'ice'
      success ? "Thermal weapons began melting the icy armor!" : "The freezing surface numbed exposed equipment!"
    when 'leathery'
      success ? "Sustained fire finally penetrated the tough hide!" : "The leathery skin absorbed the impact like natural armor!"
    when 'rotting'
      success ? "Despite the putrid smell, the attack found its mark!" : "The diseased flesh seemed to regenerate before their eyes!"
    else
      success ? "The squad found a way through the creature's defenses!" : "The kaiju's natural armor proved formidable!"
    end
  end

  def get_characteristic_flavor_text(characteristic)
    case characteristic
    when /eye/
      "The creature's unusual vision tracked every movement!"
    when /blur|fast/
      "It moved with incredible speed, almost too fast to follow!"
    when /slime/
      "Viscous fluid dripped from its body, making footing treacherous!"
    when /earth shaking/
      "Each step created tremors that could be felt for blocks!"
    when /reflective/
      "Light bounced strangely off its mirrored surface!"
    when /putrid|stinky/
      "The overwhelming stench made it hard to concentrate!"
    when /fur/
      "Its thick coat rippled in the wind like a living carpet!"
    else
      "The creature's alien nature was unsettling to witness!"
    end
  end
end
