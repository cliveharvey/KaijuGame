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
              :characteristic, :weapon, :difficulty

  def initialize
    @size = SIZES.sample
    @difficulty = (SIZES.index(@size) + 1) * 10
    @creature = CREATURES.sample
    @material = MATERIALS.values.flatten.sample
    @characteristic = CHARACTERISTICS.values.flatten.sample
    @weapon = WEAPONS.values.flatten.sample

    # Use the rich name generator
    @name_english, @name_monster = RichKaijuGenerator.generate_rich_names
  end
end
