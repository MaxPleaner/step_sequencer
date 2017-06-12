protocol = StepSequencer::SoundBuilder::EffectsComponentProtocol

class StepSequencer::SoundBuilder::DefaultEffects::Scale < protocol

  using StepSequencer.refinement(:SymbolCall)
  using StepSequencer.refinement(:StringRationalEval)
  using StepSequencer.refinement(:ObjectYieldSelf)

  # Each returns an array of floats, representing pitch change from original
  Scales = {
    equal_temperament: begin
      twelth_root_of_two = "2 ** (1 / 12)".rational_eval
      1.upto(12).reduce([twelth_root_of_two]) do |memo|
        memo.concat([memo[-1] * twelth_root_of_two])
      end
    end
  }

  def self.build(sources:, scale:, inverse: false, speed_correction: true)
    pitch_changes = Scales.fetch(scale).yield_self do |notes|
      inverse ? notes.map(&Rational(1).method(:/)) : notes
    end
    sources.map do |source|
      pitch_changes.flat_map do |pitch_change|
        builder.build(
          sources: [source],
          effect: :Pitch,
          args: [value: pitch_change, speed_correction: speed_correction]
        )
      end
    end
  end

end
