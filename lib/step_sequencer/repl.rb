class StepSequencer::REPL

  # Makes all the instance methods of Helpers available to REPL
  # The binding.pry here is not a remnant of bug-hunting,
  # this is how the REPL starts
  def self.start
    self::Helpers.new.instance_exec { binding.pry }
  end

  class Helpers
    # todo
  end

end