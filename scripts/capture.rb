require "phashion"

# capture image from webcam
`/usr/local/bin/imagesnap /Users/sylph01/capture.jpg`

# access counter
counterfile = "counter.log"

if File.exist?(counterfile)
  f = open(counterfile)
  count = f.gets.to_i
  f.close
else
  count = 0
end

count += 1
p count

f = open(counterfile,"w")
f.puts(count)
f.close

# convert image, rename image based on counter
`/usr/local/bin/convert -resize 50% -quality 65 /Users/sylph01/capture.jpg /Users/sylph01/cap_tmp/#{count}.jpg`

# remove images 10 generations older than current
if count > 10
  `rm /Users/sylph01/cap_tmp/#{count - 10}.jpg`
end

# if there is an "event" then tar the image
image1 = Phashion::Image.new("/Users/sylph01/cap_tmp/#{count}.jpg")
image2 = Phashion::Image.new("/Users/sylph01/cap_tmp/#{count - 1}.jpg")

if !image1.duplicate?(image2, :threshold => 10)
  t = Time.now
  ts = t.strftime("%Y%m%d_%H%M")
  `tar cvzf cap/#{ts}.tar.gz cap_tmp`
end

# finally rsync with the server
`rsync -a cap sylph01@s01.info:/var/www/rw/public`

