class YoutubeDownloader

  def self.download_audio(url, outdir, filename)
    system <<-SH
      cd #{outdir} && \
      youtube-dl \
          --extract-audio \
          --prefer-ffmpeg \
          --audio-format mp3 \
          --yes-playlist \
          --output #{filename} \
          --audio-quality 3 \
        #{url} \
        &>/dev/null
    SH
  end

  def self.download_playlist(url, outdir, filename)
    system <<-SH
      cd #{outdir} && \
      youtube-dl \
          --extract-audio \
          --prefer-ffmpeg \
          --audio-format mp3 \
          --audio-quality 3 \
          --output #{filename} \
        #{url} \
        &>/dev/null
    SH
  end
end
