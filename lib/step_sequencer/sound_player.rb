class StepSequencer::SoundPlayer

  using StepSequencer.refinement(:StringBlank)

  HitChar = ENV.fetch("STEP_SEQUENCER_GRID_HIT_CHAR", "x")
  RestChar = ENV.fetch("STEP_SEQUENCER_GRID_REST_CHAR", "_")

  if [HitChar, RestChar].any? &:blank?
    raise StandardError, "HitChar or RestChar cannot be just whitespace"
  end

  attr_reader :playing
  
  def initialize(sources)
    @sources = sources
    reset_state
  end

  def play(tempo: 120, string: nil, matrix: nil, limit: nil)
    @limit = limit
    if @playing
      raise( StandardError,
        "A sound player received #play when it was not in a stopped state.
         Use multiple instances instead"
      )
    end
    if matrix
      play_from_matrix(tempo: tempo, matrix: matrix)
    else
      play_from_string(tempo: tempo, string: string)
    end
    @playing = true
  end

  def stop
    reset_state
    @thread&.kill
  end

  def reset_state
    @thread = nil
    @playing = false # It can't be called multiple times at once.
                     # Use multiple instances instead.
                     # There's a check to precaution against this.
    @row_lengths = []
    @active_steps = []
    @steps_played = 0
    @limit = nil # an upper limit for steps_played, defaults to no limit
  end

  private

  def build_matrix_from_string(string)
    string.tr(" ", '').split("\n").map(&:chars).map do |chars|
      chars.map do |char|
        if char == hit_char then 1
        elsif char == rest_char then nil
        else
          raise( StandardError,
            "
              Error playing from string. Found char #{char} which is not
              one of '#{hit_char}' or '#{rest_char}'.
            "
          )
        end
      end
    end
  end

  def play_from_string(tempo:, string:)
    raise(
      StandardError,
      "one of :string or :matrix must be provided for SoundPlayer#play"
    ) if !string
    matrix = build_matrix_from_string(string)
    play_from_matrix tempo: tempo, matrix: matrix
  end

  def play_from_matrix(tempo:, matrix:)
    init_matrix_state matrix
    rest_time = calculate_rest_time(tempo)
    @thread = Thread.new do
      loop do
        if @limit && (@steps_played >= @limit)
          stop # Thread kills itself, no need to break from the loop
        end
        matrix.each_with_index do |row, row_idx|
          play_next_step_in_row row, row_idx
        end
        @steps_played += 1
        sleep rest_time
      end
    end
  end

  def play_next_step_in_row row, row_idx
    Thread.new do
      row_length = @row_lengths[row_idx]
      active_step = @active_steps[row_idx]
      Thread.stop unless active_step
      step_content = row[active_step]
      if step_content
        path = @sources[row_idx]
        Thread.new { `mpg123 #{path} 2> /dev/null` }
      end
      @active_steps[row_idx] += 1
      if @active_steps[row_idx] >= row_length
        @active_steps[row_idx] = 0
      end
    end
  end

  def calculate_rest_time(tempo)
    # Tempo is seen as quarter notes, i.e. at 120 BPM there's 0.5 seconds
    # between steps
    60.0 / tempo.to_f
  end

  def init_matrix_state(matrix)
    @row_lengths = matrix.map(&:length)
    @active_steps = Array.new((matrix.length), 0)
  end

  def hit_char
    self.class::HitChar
  end

  def rest_char
    self.class::RestChar
  end

end