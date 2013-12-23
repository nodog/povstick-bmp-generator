# 
# programming
# nodog
# 2013-12-22
#
# movie-multicrawler.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary


require "./bmp_writer.rb"
 
MOVIENAME = "multicrawler"
NLEDS = 120
BLIPLENGTH = 1
RAMPLENGTH = 255
NT = 1024 + BLIPLENGTH + 2
bmp = BMP::Writer.new(NLEDS,NT)

# need an array the length of NT which switches from black (000000) to red (0000FF) to black to white (FFFFFF) to black

black = Array.new(NT, "000000")
white = Array.new(NT, "FFFFFF")
0.upto(RAMPLENGTH) do |j|
  # red
  black[j] = "0000" + sprintf("%02x", j)
  black[j+RAMPLENGTH+BLIPLENGTH+3] = "0000" + sprintf("%02x", RAMPLENGTH-j)
  # white
  #black[j+NT/2] = sprintf("%02x", j) * 3
  #black[j+RAMPLENGTH+BLIPLENGTH+3+NT/2] =  sprintf("%02x", RAMPLENGTH-j) * 3
  # green 
  black[j+NT/2] = "0000" + sprintf("%02x", j)
  black[j+RAMPLENGTH+BLIPLENGTH+3+NT/2] =  "0000" + sprintf("%02x", RAMPLENGTH-j)
end

0.upto(BLIPLENGTH-1) do |j|
  black[RAMPLENGTH+2+j] = "00FF00"
  black[RAMPLENGTH+2+NT/2+j] = "00FF00"
end


0.upto(NLEDS - 1) do |i|
  #offset = rand(NT)
  #offset = NT - i*23 + (i % 2) * (NT/2)
  offset = NT + ((i * 20 % 1024) - 512).abs 
  0.upto(NT - 1) do |j|
    bmp[i,j] = black[(j + offset) % NT ]
  end
end 

#bmp[0,0] = "ff0000"
#bmp[1,0] = "00ff00"
#bmp[0,1] = "0000ff"
#bmp[1,1] = "ffffff"
 
bmp.save_as(MOVIENAME+".bmp")
