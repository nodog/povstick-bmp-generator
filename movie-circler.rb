# 
# programming
# nodog
# 2013-12-22
#
# movie-circler.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary

require "./bmp_writer.rb"
 
MOVIENAME = "circler"
NLEDS = 120
NTIME = 2500
DILATEFACT = 2
NYARNS = 60 
STRETCH = 0.25
WHITEYARNS = 0.50

bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)
movie = Array.new(NLEDS) { Array.new(NTIME, "000000") }

# spin the number of yarns distributed around 1/4 of the circle 
0.upto(NTIME - 1) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NYARNS - 1) do |k|
    yarn_phase = (2.0 * STRETCH) * k * Math::PI / NYARNS
    yarn_led = (14.9 * Math.cos(rads + yarn_phase) \
                + 18.0 * Math.sin(11.0 * (rads + yarn_phase)) \
                - 27.0 * Math.cos(3.0 * (rads + yarn_phase)) \
                + 60.0).floor
    red_bri = (196.0 * (k + 1) / NYARNS).floor
    whi_yarn_lim = (NYARNS * (1.0 - WHITEYARNS)).floor
    if k >= whi_yarn_lim then
      whi_bri = (196.0 * (k - whi_yarn_lim + 1) / (NYARNS - whi_yarn_lim)).floor
    else
      whi_bri = 0
    end
    movie[yarn_led][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

0.upto(NLEDS - 1) do |i|
  0.upto((NTIME * DILATEFACT) - 1) do |j|
    bmp[i,j] = movie[i][NTIME - 1 - j / DILATEFACT]
  end
end 

bmp.save_as(MOVIENAME+".bmp")
