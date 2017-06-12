class StepSequencer::Tests::TestCases

  class Player
    extend StepSequencer::Tests::TestCaseHelpers


    def self.play_a_simple_grid_from_string
      player = build_player %w{blip_1 blip_1}.map(&method(:asset_path))
      player.play(
        tempo: 240,
        limit: 16,
        string: <<-TXT,
          x _ x _
          _ _ x _
        TXT
      )
      sleep 0.5 while player.playing
    end

    def self.play_a_polyrhythmic_string
      player = build_player %w{blip_1 blip_1}.map(&method(:asset_path))
      player.play(
        tempo: 240,
        limit: 16,
        string: <<-TXT,
          x _ _
          x _ _ _
        TXT
      )
      sleep 0.5 while player.playing
    end    

  end

  class Builder

    extend StepSequencer::Tests::TestCaseHelpers

    def self.build_c_major_chord
      scale = equal_temperament_notes_with_speed_correction[0]
      result_path = builder.build(
        sources: scale.values_at(0, 4, 7),
        effect: :Overlay
      )
      [result_path]
    end

    def self.build_f_sharp_major_chord
      scale = equal_temperament_notes_with_speed_correction[0]
      result_path = builder.build(
        sources: scale.values_at(1, 6, 10),
        effect: :Overlay
      )
      [result_path]
    end

    def self.loop_a_sound_4_point_5_times
      builder.build(
        sources: [asset_path("blip_1")],
        effect: :Loop,
        args: [times: 4.5]
      )
    end

    def self.equal_temperament_notes_combined
      scale_sources = equal_temperament_notes_with_speed_correction[0]
      result_path = builder.build(
        sources: scale_sources,
        effect: :Combine
      )
      [result_path]
    end

    def self.equal_temperament_notes_with_speed_correction
      builder.build(
        sources: [asset_path("blip_1")],
        effect: :Scale,
        args: [scale: :equal_temperament]
      )
    end

    def self.equal_temperament_with_no_speed_correction
      builder.build(
        sources: [asset_path("blip_1")],
        effect: :Scale,
        args: [scale: :equal_temperament, speed_correction: false]
      )
    end

    def self.inverse_equal_temperament
      builder.build(
        sources: [asset_path("blip_1")],
        effect: :Scale,
        args: [scale: :equal_temperament, inverse: true]
      )
    end

    def self.increase_gain
      [0.25, 0.5, 0.75, 1, 1.5, 3, 5, 10].map do |val|
        builder.build(
          sources: [asset_path("blip_1")],
          effect: :Gain,
          args: [value: val]
        )
      end
    end

  end

end