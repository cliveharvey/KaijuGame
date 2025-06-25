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

    # Skill-based movement description
    movement_text = get_skill_based_text(dominant_skill, 'movement')
    texts << "🎯 #{soldier.name} #{movement_text}"

    # Skill-based action description
    action_text = get_skill_based_text(dominant_skill, 'action')
    texts << "⚔️  #{soldier.name} #{action_text}"

    # Status-specific description
    if soldier.status == :kia
      texts << "💀 #{soldier.name} #{@kia_descriptions.sample}"
    elsif soldier.status == :injured
      texts << "🩹 #{soldier.name} #{@injured_descriptions.sample}"
    elsif soldier.status == :shaken
      texts << "⚡ #{soldier.name} #{@shaken_descriptions.sample}"
    end

    # Mission outcome based on success
    outcome = soldier.success ? @success_outcomes.sample : @failure_outcomes.sample
    texts << "📊 #{outcome}"

    # Add skill improvement note if soldier survived
    if soldier.status == :alive || soldier.status == :shaken
      texts << "📈 #{soldier.name} gained valuable experience from the encounter"
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

    # Threat analysis
    if kaiju.difficulty <= 20
      threat_level = "manageable threat"
    elsif kaiju.difficulty <= 40
      threat_level = "serious challenge"
    elsif kaiju.difficulty <= 50
      threat_level = "extreme danger"
    else
      threat_level = "apocalyptic threat"
    end

    intro_texts << "🚨 Threat Analysis: #{kaiju.size.capitalize} #{kaiju.creature} poses a #{threat_level}"
    intro_texts << "💥 Estimated Casualty Risk: #{estimate_casualty_risk(squad, kaiju)}"

    intro_texts
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
end
