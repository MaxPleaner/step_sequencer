class StepSequencer::SoundBuilder::EffectsComponentProtocol

  # receives dispatch from SoundBuilder.build
  def self.build(sources:, args:)
    raise "
      ERROR.
      Something inheriting from #{self.class} didn't implement #build.
    "
  end

  class << self
    
    private

    # Helper method to call other effects
    def builder
      StepSequencer::SoundBuilder
    end

    # Any created files should be placed in here (see sound_builder.rb)
    def output_dir
      builder::OutputDir
    end

  end

end