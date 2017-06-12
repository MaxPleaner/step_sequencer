protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Pitch < protocol

  def self.build(sources:, value:, speed_correction: true)
    sources.map &change_pitch(value, speed_correction)
  end

  def self.change_pitch(value, speed_correction)
    ->(source){
      outfile = build_outfile_name(source, value)
      cmd = <<-SH
        ffmpeg -y -i #{source} -af   \
          asetrate=44100*#{value} \
          #{outfile}              \
          2> /dev/null
      SH
      system cmd
      return outfile unless speed_correction
      outfile_with_correct_speed = correct_speed(outfile, value)
      outfile_with_correct_speed
    }
  end

  class << self
    public
    def build_outfile_name(source, value)
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
    def correct_speed(outfile, pitch_change_value)
      inverse_value = Rational(1) / Rational(pitch_change_value)
      builder.build(
        sources: [outfile],
        effect: :Speed,
        args: [value: inverse_value]
      ).shift
    end
  end

end