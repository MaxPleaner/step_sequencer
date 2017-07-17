require 'securerandom'
require 'pry'
require 'espeak'
require 'method_source'
require 'colored'

Thread.abort_on_exception = true

# only top-level constant defined by the gem
class StepSequencer; end

# Require the refinements file first
refinements_file = Gem.find_files("step_sequencer/refinements.rb").shift
require refinements_file

# Also require the version file
version_file = Gem.find_files("version.rb").shift
require version_file

# Also require the youtube downloader
version_file = Gem.find_files("youtube_downloader.rb").shift
require version_file

# Add a little util method to access the refinements from other files.
class StepSequencer
  def self.refinement(name)
    StepSequencer::Refinements.const_get name
  end
end

# Require all ruby files in lib/step_sequencer, ordered by depth
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

