protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Slice < protocol

  def self.build(sources:, start_pct: nil, end_pct: nil, start_time: nil, end_time: nil)
    sources.map do |source|
      len = get_audio_length(source)
      start_time ||= calc_start_time(source, len, start_pct)
      end_time ||= calc_end_time(source, len, end_pct)
      diff = (end_time - start_time).round(6)
      outfile = build_outfile_path
      `sox #{source} #{outfile} trim #{start_time} #{diff} 2> /dev/null`
      outfile
    end
  end

  class << self
    public
    def build_outfile_path
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
    def get_audio_length(source)
      raise(
        StandardError,
        "#{source} doesn't exist (can't slice)"
      ) unless File.exists?(source)
      `soxi -D #{source}`.to_f
    end
    def calc_start_time(source, len, start_pct)
      raise(
        StandardError,
        "one of start_pct or start_time needs to be passed to Slice"
      ) unless start_pct
      start_pct_decimal = start_pct.to_f / 100.0
      len * start_pct_decimal
    end
    def calc_end_time(sourse, len, end_pct)
      raise(
        StandardError,
        "one of end_pct or end_time needs to be passed to Slice"
      ) unless end_pct      
      end_pct_decimal = end_pct.to_f / 100.0
      len * end_pct_decimal
    end
  end
end