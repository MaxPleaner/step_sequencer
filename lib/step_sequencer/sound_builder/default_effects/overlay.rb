protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Overlay < protocol

  def self.build(sources:, filename: nil)
    # ensure_correct_sample_rates(sources)
    outfile = filename || build_outfile_path
    # `sox --combine mix #{sources.join(" ")} #{outfile}`
    system <<-SH
      ffmpeg -i #{sources.join(" -i ")} \
      -filter_complex amerge -ac 2 -c:a libmp3lame -q:a 4 \
      #{outfile} 2> /dev/null
    SH
    outfile
  end

  class << self
    private
    def build_outfile_path
      "#{output_dir}/#{SecureRandom.urlsafe_base64}.mp3"
    end
    # def ensure_correct_sample_rates(sources)
    #   sources.each do |source|
    #     tmp_path = "#{SecureRandom.urlsafe_base64}.mp3"
    #     `sox -r 44.1k #{source} #{tmp_path}`
    #     unless File.exists?(tmp_path)
    #       raise StandardError, "an error occurred setting sample rate in Overlay"
    #     end
    #     `rm #{source}`
    #     `mv #{tmp_path} #{source}`
    #   end
    # end
  end

end