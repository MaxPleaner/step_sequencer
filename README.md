## Step Sequencer 

This is a Ruby tool to play mp3 files in a step sequencer.

It also handles polyrhythmic playback and building sounds using effects like
loop, combine, slice, overlay, combine, gain, speed, pitch, and download.

## Setup

### Dependencies

Some external programs need to be installed:

`mpg123 ffmpeg sox libsox-fmt-mp3`

If using the 'download' command, then `youtube-dl` is needed.

To run the tests, the program `espeak` is also required.

### Installing

```sh
gem install step_sequencer
```

```rb
require 'step_sequencer'
```

### Configuration

The main point of config is to set the location that files are generated to.
This program creates a lot of mp3s and doesn't automatically delete any of them.
By default, the location is `./.step_sequencer/generated` which is a _relative
path_. That means it's dependent on which directory the command was run from.
To use an absolute path instead, set the `STEP_SEQUENCER_OUTPUT_DIR` environment
variable.

## REPL

There is a Ruby-based REPL that ships with the gem.
Launch it from shell with:

```sh
step_sequencer repl
```

and type 'help' or 'quit'. It will show the names of some helper functions
that have been made available.
Still, the REPL assumes familiarity with the underlying Ruby API.

## Ruby API

There are two main components: `StepSequencer::SoundBuilder` and
`StepSequencer::SoundPlayer`

### StepSequencer::SoundBuilder

This offers only one method, `.build`, which is overloaded and dispatches to a
number of other classes (each of which is responsible for
a single effect). 

_note_

> The definitions of the default effects can be found in the source code at `lib/step_sequencer/sound_builder/default_effects/`. To add a custom effect, use one of the existing ones as a template and then add a reference to the class
in the `StepSequencer::SoundBuilder::EffectsComponents` hash.

Here is an example of using the builder. It takes a single input mp3 and creates 12 new ones,
spanning the "equal temperament" tuning.

```rb
builder = StepSequencer::SoundBuilder
filenames = builder.build(
  sources: ["middle_c.mp3"],
  effect: :Scale,
  args: [{scale: :equal_temperament}]
).first
# the :Scale effect returns a nested array (one array for each input source)
# so after calling .first, filenames refers to a regular array of 12 file paths.
```

The `:Scale` effect also allows an `inverse: true` key in `args` which will
set all pitch change values to their inverse (creating a descending scale).

Right now there is only the equal temperament option, more may be added later.

Now say I want to apply a 150% gain to all these files:

```rb
# returns array of paths, one for each source
filenames = builder.build(
  sources: filenames
  effect: :Gain,
  args: [{value: 1.5}]
)
```

Other builtin effects:

_change speed_

```rb
# returns array of paths, one for each source
filenames = builder.build(
  sources: filenames,
  effect: :Speed,
  args: [{value: 0.5}]
)
```

_change pitch_

```rb
# returns array of paths, one for each source
filenames = builder.build(
  sources: filenames,
  effect: :Pitch,
  args: [{value: 2}]
)
# By default this will adjust the speed so that only the pitch changes.
# However the `speed_correction: false` arg will prevent this.
```

_loop_

```rb
# returns array of paths, one for each source
filenames = builder.build(
  sources: filenames,
  effect: :Loop,
  args: [{times: 1.5}]
)
```

_slice_

```rb
# returns array of paths, one for each source
filenames = builder.build(
  sources: filenames,
  effect: :Slice,
  args: [{start_time: 0.5, end_time: 1}] # A 0.5 second slice
  # start_pct and end_pct can be used for percentage-based slicing, e.g.
  # {start_pct: 25, end_pct: 75} which will take a 50% slice from the middle.
)
```

_combine_

```rb
# returns single path
path = builder.build(
  sources: filenames,
  effect: :Combine,
  args: [{filename: "foo.mp3"}], # filename arg is optional,
                                 # and one will be auto-generated otherwise.
)
```

_overlay_

```rb
# returns single path
path = builder.build(
  sources: filenames,
  effect: :Overlay,
  args: [{filename: "foo.mp3"}], # filename arg is optional,
                                 # and one will be auto-generated otherwise.
)
```

As the above examples illustrate,  `#build` is always given an array of sources
(audio paths). `effect` is always a symbol, and although it can be ommitted if
it's empty, `args` is always a array, the signature of which is dependent on the
specific effects component's implementation.

### StepSequencer::SoundPlayer

Playing sounds is a two part process. First, the player must be initialized, which is when the sounds are mapped to rows.

For example, say I want to plug in the sounds I created earlier using
`StepSequencer::SoundBuilder#build`. I have 12 sounds and I want to give each
of them their own row in the sequencer. This is pretty easy to do:

```rb
player = StepSequencer::SoundPlayer.new(filenames)
```

After `#initialize`, only one other method needs to get called, and that's `play`.
As you might have expected by now, it's overloaded as well:

```rb
# This will play the ascending scale, there is 1 row for each note
player.play(
  tempo: 240
  string: <<-TXT
  x _ _ _ _ _ _ _ _ _ _ _ 
  _ x _ _ _ _ _ _ _ _ _ _ 
  _ _ x _ _ _ _ _ _ _ _ _ 
  _ _ _ x _ _ _ _ _ _ _ _ # comments can be added too
  _ _ _ _ x _ _ _ _ _ _ _
  _ _ _ _ _ x _ _ _ _ _ _ 
  _ _ _ _ _ _ x _ _ _ _ _ 
  _ _ _ _ _ _ _ x _ _ _ _ 
  _ _ _ _ _ _ _ _ x _ _ _
  _ _ _ _ _ _ _ _ _ x _ _ 
  _ _ _ _ _ _ _ _ _ _ x _ 
  _ _ _ _ _ _ _ _ _ _ _ x 
  TXT
)
```

To use something other than `x` or `_`, set the options `:hit_char` and `:rest_char`.

The following plays the same notes, but with nested arrays and the `:matrix` option.
The hits/rests here are denoted by 1 and nil, respectively 

```rb
player.play(
  tempo: 240,
  matrix: 0.upto(11).reduce([]) do |rows, i|
   rows.push Array.new(12, nil)
   rows[-1][i] = 1
   rows
 end  
)
```

Some other notes:

- this intentionally doesn't validate that the rows
are the same length. This is so that polyrhythms can be played.
- by default the rows are looped forever in a background thread. To stop, simply
`player.stop`. To trigger playback for a limited time only, pass a `limit` option
which is an integer representing a number of _total hits_. I.e. if I wanted to
play the aformentioned 12-step grid 4 times, I'd pass a limit of 48.
- although there is no option to make `play` happen synchronously, just use
something like `sleep 0.5 while player.playing`
- the tempo can be understood as BPM in quarter notes. So to get the same speed
as 16th notes at 120 BPM, use a tempo of 480. The default is 120.
- The player isn't set up to be manipulated while playing. Use a new instance instead.

## Todos

- precompile the grid into a single mp3. this will result in optimal playback
- support inlining effect directives into the grid (not just a separate build
stage). Part of this could be supporting different note flags, such as whole notes,
half notes, etc.

## Tests

The tests are found in lib/step_sequencer/tests.rb. They are not traditional
unit tests since the value cannot be automatically determined to be correct.
Rather, it generates sounds and then plays them back for manual aural
validation. 

A couple small (1 second) mp3s are bundled with the gem and are used in the tests.
To run the tests from the command line, use the executable included with the gem:

```rb
step_sequencer test
```

They can also be run from code: `require 'step_sequencer'` then
`StepSequencer::Tests.run`.

## Downloading music from youtube

Bundled into this gem is [youtube_audio_downloader](http://github.com/maxpleaner/youtube-audio-downloader),
which provides a simple command to download audio from youtube:

```rb
YoutubeAudioDownloader.download(
  "https://www.youtube.com/watch?v=Niuy_GqpU1s",
  "~/Music",
  "necrophagist_seven.mp3"
)
```