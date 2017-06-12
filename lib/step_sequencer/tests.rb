require 'espeak'
require 'method_source'

# =============================================================================
# A custom test runner. The tests themselves are in test_cases.rb
# Usage: StepSequencer::Tests.run
# The protected method run_test_collection can also be used; it's more modular.
# =============================================================================

class StepSequencer::Tests

  # Runs all the test cases, speaking the method name and playing the result.
  #
  # Returns the results from the tests, for manual inspection from Pry
  #
  def self.run
    cleanup
    run_test_collection(builder_tests) do |fn_name, test_case|
      result = run_test_case(builder_tests, fn_name, test_case)
      result.tap &method(:play_sounds)
    end
    run_test_collection(player_tests) do |fn_name, test_case|
      run_test_case(player_tests, fn_name, test_case)
    end
  end

  # shared 'around' hook for tests
  def self.run_test_case(test_class, fn_name, test_case)
    speak_fn_name fn_name
    puts fn_name
    test_class.method(fn_name).source.display
    test_case.call
  end

  class << self
    protected

    def builder_tests
      StepSequencer::Tests::TestCases::Builder
    end
    def player_tests
      StepSequencer::Tests::TestCases::Player
    end

    def speak_fn_name fn_name
      say fn_name.to_s.gsub("_", " ")
    end

    def cleanup
      dir = StepSequencer::SoundBuilder::OutputDir
      Dir.glob("#{dir}/*.mp3").each &File.method(:delete)
    end

    # Runs all the methods in a class, optionally filtered via :only and
    # :accept options (arrays of symbols referencing methods of klass).
    #
    # If a block is provided, then it is passed the name as a symbol and
    # the test case as a proc. The proc will need to be called manually
    # from the block, and the block should return the result.
    # This allows a before/after hook to be inserted.
    # With no given block, the test case is automatically run.
    #
    # Returns a hash mapping test case names (symbols) to results
    #
    def run_test_collection(klass, only: nil, except: nil, &blk)
      klass.methods(false).reduce({}) do |memo, fn_name|
        next memo if only && !only.include?(fn_name)
        next memo if except && except.include?(fn_name)
        memo[fn_name] = if blk
          blk.call(fn_name, ->{klass.send fn_name})
        else
          klass.send(fn_name)
        end
        memo
      end
    end

    def say(phrase)
      ESpeak::Speech.new(phrase).speak
    end
    def play_sounds(sounds, tempo: 800)
      sleep_time = 60.0 / tempo.to_f
      sounds.flatten.each do |path|
        `mpg123 #{path} 2> /dev/null`
        sleep sleep_time
      end
    end
  end

  # Helpers made available to test cases (if they include the module)
  module TestCaseHelpers
    protected
    def asset_path(name)
      Gem.find_files("step_sequencer/test_assets/#{name}.mp3")[0]
    end
    def builder
      StepSequencer::SoundBuilder
    end
    def build_player(sources)
      StepSequencer::SoundPlayer.new sources
    end
  end

end