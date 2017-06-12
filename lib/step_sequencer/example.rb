sounds = [
  "blip_1.mp3",
  "blip_1.mp3",
  "blip_1.mp3",
]

4.times do
  sounds.each do |sound|
    Thread.new do
      `mpg123 #{sound} 2> /dev/null`
    end
  end
  sleep 0.5
end