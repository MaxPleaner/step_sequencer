## Step Sequencer 

#### About

This is a Ruby tool to play mp3 files in a step sequencer.

It also handles polyrhythmic playback and building sounds using effects like 

#### Depedencies

Some external programs need to be installed:

`mpg123 ffmpeg sox libsox-fmt-mp3`

To run the tests, the program `espeak` is also required.

#### Installing

```sh
gem install step_sequencer
```

```rb
require 'step_sequencer'
```

#### Usage

There are two main components: `StepSequencer::SoundBuilder` and
`StepSequencer::SoundPlayer`

##### 1. **`StepSequencer::SoundBuilder`**

This offers only one public method, `.build`, which is drastically overloaded
and dispatches to a number of other classes (each of which is responsible for
a single effect). The definitions of these can be found in the source code at
 `lib/step_sequencer/sound_builder/default_effects/`. To add a custom effect,
 use one of the existing ones as a template and then add a reference to the class
 in the `StepSequencer::SoundBuilder::EffectsComponents` hash.

Here is an example. It takes a single input mp3 and creates 12 new ones,
spanning the "equal temperament" tuning.

```rb
# returns nested array (array of generated sounds for each source)
builder = StepSequencer::SoundBuilder
filenames = builder.build(
  sources: ["middle_c.mp3"],
  effect: :Scale,
  args: [{scale: :equal_temperament}]
)
```

The `:Scale` effect also allows an `inverse: true` key in `args` which will
set all pitch change values to their inverse (creating a descending scale).

Now say I want to apply a 150% gain to all these files:

```rb
# returns array of paths, one for each source
new_filenames = builder.build(
  sources: filenames.shift,
  effect: :Gain,
  args: [{value: 1.5}]
)
```

Other builtin effects:

_change speed_ (returns array of paths, one for each source)

```rb
new_filenames = builder.build(
  sources: new_filenames,
  effect: :Speed,
  args: [{value: 0.5}]
)
```

_change pitch_ (returns array of paths, one for each source)

```rb
new_filenames = builder.build(
  sources: filenames,
  effect: :Pitch,
  args: [{value: 2}]
)
# By default this will adjust the speed so that only the pitch changes.
# However the `speed_correction: false` arg will prevent this.
```

_loop_ (returns array of paths, one for each source)

```rb
new_filenames = builder.build(
  sources: filenames,
  effect: :Loop,
  args: [{times: 1.5}]
)
```

_slice_ (returns array of paths, one for each source)

```rb
new_filenames = builder.build(
  sources: filenames,
  effect: :Slice,
  args: [{start_time: 0.5, end_time: 1}] # A 0.5 second slice
  # start_pct and end_pct can be used for percentage-based slicing, e.g.
  # {start_pct: 25, end_pct: 75} which will take a 50% slice from the middle.
)
```

_combine_ (returns single path)

```rb
new_filenames = builder.build(
  sources: filenames,
  effect: :Combine,
  args: [{filename: "foo.mp3"}], # filename arg is optional,
                                 # and one will be auto-generated otherwise.
)
```

_overlay_ (returns single path)

```rb
new_filenames = builder.build(
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

#### 2. **`StepSequencer::SoundPlayer`**

Playing sounds is a two part process. First, the player must be initialized,
which is when the sounds are mapped to rows.

For example, say I want to plug in the sounds I created earlier using
`StepSequencer::SoundBuilder#build`. I have 12 sounds and I want to give each
of them their own row in the sequencer. This is pretty easy to do:

```rb
player = StepSequencer::SoundPlayer.new(filenames)
```

After `#initialize`, only one other method needs to get called, and that's `play`.
As you might have expected by now, it's overloaded as well:

```rb
# This will play the descending scale, there is 1 row for each note
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

#### Todos

- precompile the grid into a single mp3. this will result in optimal playback
- make a nice REPL

#### Tests

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