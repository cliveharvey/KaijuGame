class BattleText
  def initialize
    @movement_success = [
      "reached to an elevated position",
      "moved towards the target",
      "took cover",
      "moved to intercept the target",
      "started securing civilians",
      "moved to block the targets escape"
    ]

    @movement_failure = [
      "took cover in the open",
      "ran recklessly towards the target",
      "took position in a rickety building",
      "moved right under the target",
      "began shooting immediately",
      "couldnt keep up with the squad"
    ]

    @action_success = [
      "targeted the beasts exposed areas",
      "pulled civilians to safety",
      "helped team members avoid the beasts attacks",
      "secured the area",
      "suppressed the beasts movements",
      "overwhelmed the beast with attacks"
    ]

    @action_failure = [
      "shot recklessly at the beast",
      "had equipment failure",
      "cowered behind cover",
      "lost their bearings",
      "was trampled by excaping civilians",
      "attacked the beast head on"
    ]

    @outcome_success = [
      "Civilians had time to escape!",
      "The beast became distracted from its rampage!",
      "Assets were secured!",
      "The beast routed away from civilians!",
      "The beast began to retreat!",
      "Civilians were medevaced!"
    ]

    @outcome_failure = [
      "More buildings were destroyed",
      "Many were cut down by the beast",
      "The beast moved unhampered",
      "The beast roared out in victory",
      "The beast continued its assault",
      "Fires broke out everywhere"
    ]

    @injury_text = [
      "was flung through the air by the beasts vicious attack",
      "was hit by debris from the beasts attack",
      "was hit by falling cement from the damaged buildings",
      "was unabled to get out of the way of an attack",
      "was caught off guard by the beast"
    ]
  end

  def battle_summary(soldier)
    texts = []

    # Movement
    movement = soldier.success ? @movement_success.sample : @movement_failure.sample
    texts << "#{soldier.name} #{movement}"

    # Action
    action = soldier.success ? @action_success.sample : @action_failure.sample
    texts << "#{soldier.name} #{action}"

    # Outcome
    outcome = soldier.success ? @outcome_success.sample : @outcome_failure.sample
    texts << outcome

    # Injury if applicable
    if soldier.status != :alive
      texts << "#{soldier.name} #{@injury_text.sample}"
    end

    texts
  end
end
