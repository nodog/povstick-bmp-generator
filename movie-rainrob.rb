# 
# programming
# nodog
# 2014-05-26
#
# movie-circler.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary

require "./bmp_writer.rb"
 
MOVIENAME = "rainrob"
NLEDS = 120
NTIME = 5000
DILATEFACT = 1
NPIXCOL = 6
NDRAWOUT = 2
NDRAWIN = 1

bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)
c_red = "0000FF" 
c_orange = "007FFF"
c_yellow = "00FFFF"
c_green = "00FF00"
c_blue = "FF0000"
c_indigo = "82004B"
c_violet = "FF008B"
c_half_violet = "440022"
c_white = "888888"
c_black = "000000"
movie = Array.new(NLEDS) { Array.new(NTIME, c_half_violet) }

# straightforward rainbow
#rainbow = [Array.new(NPIXCOL, c_red), Array.new(NPIXCOL, c_orange), 
#  Array.new(NPIXCOL, c_yellow),  Array.new(NPIXCOL, c_green),  Array.new(NPIXCOL, c_blue), 
#  Array.new(NPIXCOL, c_indigo),  Array.new(NPIXCOL, c_violet)].flatten 

# drawn rainbow
rainbow = [Array.new(NDRAWOUT, c_white), Array.new(NDRAWIN, c_black), Array.new(NDRAWIN, c_white), 
  Array.new(NPIXCOL, c_red), Array.new(NPIXCOL, c_orange), 
  Array.new(NPIXCOL, c_yellow),  Array.new(NPIXCOL, c_green),  Array.new(NPIXCOL, c_blue), 
  Array.new(NPIXCOL, c_indigo),  Array.new(NPIXCOL, c_violet),
  Array.new(NDRAWIN, c_white), Array.new(NDRAWIN, c_black), Array.new(NDRAWOUT, c_white), ].flatten 

# move the rainbow back and forth across the field
0.upto(NTIME - 1) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  rainbow_edge = 2
  rainbow_amp = (NLEDS - rainbow.length - rainbow_edge - 1) / 2
  rainbow_start = rainbow_edge + (rainbow_amp * Math.cos(rads) + 0.5).floor + rainbow_amp 
  rainbow_end = rainbow_start + rainbow.length - 1
  rainbow_start.upto(rainbow_end) do |i|
    puts "#{i} #{j} #{rainbow_start} #{rainbow_end}"
    movie[i][j] = rainbow[i - rainbow_start]
  end
end
 
0.upto(NLEDS - 1) do |i|
  0.upto((NTIME * DILATEFACT) - 1) do |j|
    bmp[i,j] = movie[i][NTIME - 1 - j / DILATEFACT]
  end
end 

bmp.save_as(MOVIENAME+".bmp")
