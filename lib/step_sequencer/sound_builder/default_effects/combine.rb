protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Combine < protocol

  # This combines the files one after another.
  # To make them overlap, use Overlay

  def self.build(sources:, filename: nil)
    concat_cmd = "concat:#{sources.join("|")}"
    outfile = filename || generate_outfile_path(sources)
    system %{ffmpeg -y -i "#{concat_cmd}" -c copy #{outfile} 2> /dev/null }
    outfile
  end

  # The following is an alternate script to combine:
  # `sox #{sources.join(" ")} #{outfile}`

  class << self
    private
    def generate_outfile_path(sources)
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
  end

end