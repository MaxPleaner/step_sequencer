protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Speed < protocol

  def self.build(sources:, value:)
    sources.map do |path|
      outfile = build_outfile_path path, value
      `sox #{path} #{outfile} tempo #{value.to_f} 2> /dev/null`
      outfile
    end
  end

  class << self
    protected
    def build_outfile_path path, value
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
  end

end