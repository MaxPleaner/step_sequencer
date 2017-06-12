protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Loop < protocol

  def self.build(sources:, times:)
    num_full_loops = times.to_i # rounds down
    num_partial_loops = times - num_full_loops.to_f
    outfiles = build_full_loops(sources, num_full_loops)
    if num_partial_loops > 0
      outfiles = build_partial_loops(sources, outfiles, num_partial_loops)
    end
    outfiles
  end

  class << self
    protected
    def build_outfile_path
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
    def build_partial_loops(sources, outfiles, num_partial_loops)
      outfiles.map.with_index do |outfile, idx|
        source = sources[idx]
        sliced = slice_source(source, num_partial_loops)
        combine([outfile, sliced])
      end
    end
    def build_full_loops(sources, num_full_loops)
      sources.map do |source|
        combine(Array.new(num_full_loops, source))
      end
    end
    def slice_source(source, num_partial_loops)
      builder.build(
        sources: [source],
        effect: :Slice,
        args: [{start_pct: 0.0, end_pct: (num_partial_loops * 100) }]
      )[0]
    end
    def combine(sources)
      builder.build(
        sources: sources,
        effect: :Combine
      )
    end
  end

end