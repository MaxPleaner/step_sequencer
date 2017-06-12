require_relative './lib/version.rb'
Gem::Specification.new do |s|
  s.name        = "step_sequencer"
  s.version     = StepSequencer::VERSION
  s.date        = "2017-06-05"
  s.summary     = "step sequencer (music tool)"
  s.description = ""
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["max pleaner"]
  s.email       = 'maxpleaner@gmail.com'
  s.required_ruby_version = '~> 2.3'
  s.homepage    = "http://github.com/maxpleaner/step_sequencer"
  s.files       = Dir[
                        "lib/**/*.rb", "bin/*", "*.md",
                        "lib/step_sequencer/test_assets/*.mp3",
                        "LICENSE"
                     ]
  s.require_path = 'lib'
  s.required_rubygems_version = ">= 2.6.11"
  s.add_dependency 'thor', "~> 0.19"
  s.add_dependency 'method_source', "~> 0.8"
  s.add_dependency 'espeak-ruby', "~> 1"
  s.add_dependency 'pry', "~> 0.10"
  s.add_dependency 'colored', "~> 1.2"
  s.executables = Dir["bin/*"].map &File.method(:basename)
  s.license     = 'MIT'
end
