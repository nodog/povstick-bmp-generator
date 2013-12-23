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
DILATEFACT = 1
NCALC = NLEDS / 2
NGROWTH = (NCALC * (NCALC + 1)) / 2
NMUTATE = 100
NDECAY = NGROWTH
NSILENCE = 100
NTIME = NGROWTH + NMUTATE + NDECAY + NSILENCE

bmp = BMP::Writer.new(NLEDS, NTIME)

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
      movie[i][j] = (i == nsequence) || (i > nseqlim) ? "0000FF" : "000000"
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
  0.upto(NLEDS - 1) do |i|
      movie[i][j] = "0000FF"
  end
  movie[rand(NLEDS)][j] = "FFFFFF"
end

# decay phase
nsequence = 0
nseqlim = 0
(NGROWTH + NMUTATE).upto(NGROWTH + NMUTATE + NDECAY - 1) do |j|
  0.upto(NLEDS - 1) do |i|
    if i < NLEDS / 2 then
      movie[i][j] = (i == nsequence) || (i > nseqlim) ? "0000FF" : "000000"
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
  0.upto(NTIME - 1) do |j|
    bmp[i,j] = movie[i][j]
  end
end 

bmp.save_as(MOVIENAME+".bmp")
