# 
# programming
# nodog
# 2014-03-03
#
# movie-matrixle.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary


require "./bmp_writer.rb"
 
MOVIENAME = "matrixle"
NLEDS = 120
RAMPINLENGTH = 128
RAMPOUTLENGTH = 5048
MAXBRIGHT = 192
NT = 16000
bmp = BMP::Writer.new(NLEDS, NT)

# need an array the length of NT which switches from black (000000) 
#   to green (00FF00) to black 

# make a stripe that I will copy into the final matrix at offsets for each column
stripe = Array.new(NT, "000000")

# make the brightness inramp
0.upto(RAMPINLENGTH) do |j|
  bright = MAXBRIGHT * j / (RAMPINLENGTH - 1)
  stripe[j] = "00" + sprintf("%02x", bright) + "00"
  #p stripe[j]
end

# make the brightness outramp
0.upto(RAMPOUTLENGTH) do |j|
  loc = RAMPINLENGTH + j
  bright = MAXBRIGHT * (RAMPOUTLENGTH - j) / (RAMPOUTLENGTH - 1)
  stripe[loc] = "00" + sprintf("%02x", bright) + "00"
  #p stripe[loc]
end

# make one copy of the stripe for each LED, set at a vertical offset
0.upto(NLEDS - 1) do |i|
  offset = rand(NT)
  0.upto(NT - 1) do |j|
    # reversed here b/c time is displayed up from the bottom on the bmp
    bmp[i, NT - 1 - j] = stripe[(j + offset) % NT ]
  end
end 

#bmp[0,0] = "ff0000"
#bmp[1,0] = "00ff00"
#bmp[0,1] = "0000ff"
#bmp[1,1] = "ffffff"
 
bmp.save_as(MOVIENAME+".bmp")
