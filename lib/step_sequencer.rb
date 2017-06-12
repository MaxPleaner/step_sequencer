require 'securerandom'
require 'pry'
require 'espeak'
require 'method_source'

Thread.abort_on_exception = true

# only top-level constant defined by the gem
class StepSequencer; end

# Require the refinements file first
refinements_file = Gem.find_files("step_sequencer/refinements.rb").shift
require refinements_file

# Add a little util method to access the refinements from other files.
class StepSequencer
  def self.refinement(name)
    StepSequencer::Refinements.const_get name
  end
end

# Require all ruby files in lib/step_sequencer, ordered by depth
# This loads the refinements file again but it's no big deal
Gem.find_files("step_sequencer/**/*.rb")
   .sort_by { |path| path.count "/" }
   .each &method(:require)

# Add the default effects to the sound builder
StepSequencer::SoundBuilder.class_exec do
  self::EffectsComponents = self::DefaultEffects.constants
  .reduce({}) do |memo, name|
    memo.tap { memo[name] = self::DefaultEffects.const_get name }
  end
end

