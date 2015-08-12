# CREATE EXAMPLE PLOT

library(ggplot2)  # graphics library
data(iris)  # Load data

p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p

# SAVE AS HIGH RESOLUTION RASTER (.tiff)
# Can be embeded in Word or saved as standalone file
ggsave("iris.tiff",
       p,
       units="in",
       width=3.25,   #1 column
       height=3.25, 
       dpi=1200,   # ES&T. 300-600 at PLOS One,
       compression = "lzw",  # PLOS One 44MB w/out compression, 221KB w/compression
        family="Arial")  # ggplot default.  Could set to others depending on journal
# No need to modify for color figure.  Uses RGB color mode by default
# Prints @ 3x3 in Word.  White space in margins?
# View image (Word) and reformat if necessary

# Add longer y-axis title
p2 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point() +
  ylab("This is a longer y-axis title that may require breaking across a new line")
p2

ggsave("iris.tiff",
       p2,
       units="in",
       width=3.25,   #1 column
       height=3.25, 
       dpi=1200,   # ES&T. 300-600 at PLOS One,
       compression = "lzw")

# Now wrap title across two lines.
p3 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point() +
  ylab("This is a longer y-axis title that may \n require breaking across a new line")
p3

ggsave("iris.tiff",
       p3,
       units="in",
       width=3.25,   #1 column
       height=3.25, 
       dpi=1200,   # ES&T. 300-600 at PLOS One,
       compression = "lzw")


# SAVE AS .eps
# Might be viewable in Word.  Can be previewed in Adobe Acrobat or GhostView (freeware,
# requires Ghostscript), among others.
ggsave("iris.eps",
       p,
       units="in",
       width=3.25,   #1 column
       height=3.25)  
# Convert to .pdf and view in Adobe Pro (prints at 3x3)
# View directly in Ghostview



# Embed fonts.  In theory, can be done with {grDevices} embedFonts() or
# {extrafont} embed_font().  Both require installation of Ghostscript (freeware).
# Package help file: This function is not necessary if you just use the standard 
# default fonts for PostScript and PDF output.

# More info on embeding plots
# http://www.fromthebottomoftheheap.net/2013/09/09/preparing-figures-for-plos-one-with-r/#comment-1253572863
# http://www.r-bloggers.com/how-to-use-your-favorite-fonts-in-r-charts/

# MULTI PANEL PLOTS
# 2 panel plot
library(grid)
tiff("iris2panel.tiff",
     units = "in",
     width = 6.5,  # 2 columns
     height = 3.25,
     res=1200)
grid.newpage()
pushViewport(viewport(layout=grid.layout(1,2)))
print(p, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(p3, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
dev.off()
     

