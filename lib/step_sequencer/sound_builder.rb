class StepSequencer::SoundBuilder

  # Check the ENV config for an output dir, otherwise use a default one
  OutputDir = ENV.fetch(
    "STEP_SEQUENCER_OUTPUT_DIR",
    "./.step_sequencer/generated"
  ).tap do |path|
    `mkdir -p #{path}`
    raise(
      StandardError,
      "#{path} dir couldn't be created/found. Maybe create it manually."
    ) unless File.directory?(path)
  end

  def self.build(sources:, effect:, args: [{}])
    effect_class = effects_components[effect]
    effect_class.build({sources: sources}.merge *args)
  end

  class << self
    public
    def effects_components
      StepSequencer::SoundBuilder::EffectsComponents
    end
  end
  
end