# 
# programming
# nodog
# 2013-12-22
#
# movie-grower.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary


require "./bmp_writer.rb"
 
MOVIENAME = "grower"
NLEDS = 120
BRIGHTEST = 255
DILATEFACT = 2
NCALC = NLEDS / 2
NGROWTH = (NCALC * (NCALC + 1)) / 2
NMUTATE = 2000
NPULSES = 8
NDECAY = NGROWTH
NSILENCE = 200
NTIME = NGROWTH + NMUTATE + NDECAY + NSILENCE

bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)

# need an array the length of NT which switches from black (000000) to red (0000FF) to black to white (FFFFFF) to black

movie = Array.new(NLEDS) { Array.new(NTIME, "000000") }
#@pixels = Array.new(@height) { Array.new(@width) { "000000" } }

# growth phase
nsequence = 0
nseqlim = NLEDS / 2 - 1
0.upto(NGROWTH - 1) do |j|
  0.upto(NLEDS - 1) do |i|
    #movie[i][j] = "0000" + sprintf("%02x", j * BRIGHTEST / NGROWTH)
    if i < NLEDS / 2 then
      movie[i][j] = (i == nsequence) || (i > nseqlim) ? "00007F" : "000000"
    else
      movie[i][j] = movie[NLEDS - 1 - i][j]
    end
  end
  nsequence += 1
  if nsequence > nseqlim then
    nsequence = 0
    nseqlim -= 1
  end
end

# mutate phase
(NGROWTH).upto(NGROWTH + NMUTATE - 1) do |j|
  mutate_progress = 1.0 * (j - NGROWTH) / NMUTATE
  rads = mutate_progress * (NPULSES + 0.5) * Math::PI * 2.0
  red_amp = 63 * (1.0 - mutate_progress)
  # red is a little too dark in comparison, so sqrt
  red_hgt = 63 * Math.sqrt(1.0 - mutate_progress)
  whi_amp = 63 * mutate_progress
  red_bri = [red_amp * Math.cos(rads + Math::PI) + 3.0 * red_amp, 0.0].max 
  whi_bri = [whi_amp * Math.cos(rads) + 3.0 * whi_amp, 0.0].max
  #print [mutate_progress, rads, red_amp, whi_amp, red_bri, whi_bri] if (whi_amp > 255.0) || (red_amp > 255.0)
  0.upto(NLEDS - 1) do |i|
      movie[i][j] = sprintf("%02x%02x%02x", whi_bri.floor, whi_bri.floor, [red_bri.floor, whi_bri.floor].max)
      #movie[i][j] = sprintf("0000%02x", red_bri.floor)
  end
  movie[rand(NLEDS)][j] = "FFFFFF"
  movie[rand(NLEDS)][j] = "000000"
  movie[rand(NLEDS)][j] = "000000"
  movie[rand(NLEDS)][j] = "0000FF"
end

# decay phase
nsequence = 0
nseqlim = 0
(NGROWTH + NMUTATE).upto(NGROWTH + NMUTATE + NDECAY - 1) do |j|
  0.upto(NLEDS - 1) do |i|
    if i < NLEDS / 2 then
      movie[i][j] = (i == nsequence) || (i > nseqlim) ? "7F7F7F" : "000000"
    else
      movie[i][j] = movie[NLEDS - 1 - i][j]
    end
  end
  nsequence -= 1
  if nsequence < 0 then
    nseqlim += 1
    nsequence = nseqlim
  end
end

0.upto(NLEDS - 1) do |i|
  0.upto((NTIME * DILATEFACT) - 1) do |j|
    bmp[i,j] = movie[i][j / DILATEFACT]
  end
end 

bmp.save_as(MOVIENAME+".bmp")
