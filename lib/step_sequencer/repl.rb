class StepSequencer::REPL

  # Makes all the instance methods of Helpers available to REPL
  # The binding.pry here is not a remnant of bug-hunting,
  # this is how the REPL starts
  def self.run
    self::Helpers.new.instance_exec do
      docs
      Pry.start(self)
    end
  end

  class Helpers

    HelpSections = {
      play: "
        Usage: play #{"\"<path>\"".blue}
        - plays the file in its own thread using mpg123
        - hides the output
      ",
      combine: "
        Usage: combine #{"\"[<paths>]\"".blue}
        - note that this combines them sequentially.
          for concurrent playback, use overlay
        - returns a single path.
      ",
      gain: "
        Usage: gain #{"\"<path>\"".blue}, #{"<value>".blue}
        - <value> is a float, e.g. 0.5 for half and 2.0 for double
        - returns a single path
      ",
      loop: "
        Usage: loop #{"\"<path>\"".blue}, #{"<num_times>".blue}
        - <num_times> can be a int or a float. if it's a float, then the last
          loop will include only part of the original sample.
        - returns a single path

      ",
      overlay: "
        Usage: overlay #{"\"[<paths>]\"".blue}
        - combines files so they play on top of one another
        - returns a single path
      ",
      pitch: "
        Usage: pitch #{"\"<path>\"".blue}, #{"<value>".blue}, #{"<speed_correct>".blue}
        - <value> here is a integer/float, e.g. 0.5 for half and 2.0 for double.
        - <speed_correct> defaults to true. It will prevent the pitch shift from
          changing the speed.
        - returns a single path
      ",
      scale: "
        Usage: scale #{"\"<path>\"".blue}, #{"<inverse>".blue}
        - This will generate 12 notes of the equal temperament tuning
        - <inverse> defaults to false. If true then the generated notes will
          be downtuned from the original (descending).
      ",
      slice: "
        Usage: slice #{"\"<path>\"".blue} #{"<start>".blue} #{"<end>".blue}
        - <start> and <end> are floats referring to a number of seconds.
          Providing values of 2.0 and 3.5 would create a 1.5 second slice
        - returns a single path
      ",
      speed: "
        Usage: speed #{"\"<path>\"".blue} #{"<value>".blue}
        - <value> is a integer/float, e.g. 0.5 for half and 2.0 for double
        - returns a single path
      "
    }

    def docs(section=nil)
      section = section.to_sym if section
      if section && (doc = self.class::HelpSections[section])
        puts HelpSections[section]
      elsif section
        puts "
          docs section #{section} not found.
          Enter #{"docs".blue} to see a list of sections
        ".red
      else
        puts "
          StepSequencer
          #{"================"}

          Usage: docs #{"\"command\"".blue}
          where #{"command".blue} is one of:
          #{self.class::HelpSections.keys.join(", ")}
        "
      end
    end

    def builder
      StepSequencer::SoundBuilder
    end

    def player
      StepSequencer::Player
    end

    def combine(paths)
      builder.build(
        sources: paths, effect: :Combine
      )
    end

    def gain(path, val)
      builder.build(
        sources: [path], effect: :Gain, args: [value: val]
      )[0]
    end

    def loop(path, times)
      builder.build(
        sources: [path], effect: :Loop, args: [times: val]
      )[0]
    end

    def overlay(paths)
      builder.build(
        sources: paths, effect: :Overlay
      )
    end

    def pitch(path, val, speed_correct=true)
      builder.build(
        sources: [path], effect: :Pitch,
        args: [{times: val, speed_correction: speed_correct}]
      )[0]
    end

    def scale(path, inverse)
      builder.build(
        sources: [path], effect: :Scale,
        args: [{scale: :equal_temperament, inverse: inverse}]
      )[0]
    end

    def slice(path, start_time, end_time)
      builder.build(
        sources: [path], effect: :Slice,
        args: [{start_time: start_time, end_time: end_time}]
      )[0]
    end

    def speed(path, val)
      builder.build(
        sources: [path], effect: :Speed,
        args: [{value: val}]
      )[0]
    end

    def play(path)
      Thread.new { `mpg123 #{path} 2> /dev/null` }
    end

  end

end