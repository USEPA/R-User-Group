# LaTeX/pandoc/Rmd issues

1. First issue when trying to render to pdf from an Rmd is pandoc.  It is not installed by default and the versions available from epel or old. 
    - solution 1: If rstudio-server or shiny-server are installed, those come with a version of `pandoc` and `pandoc-citeproc`.  Easiest solution for all users is to add the this folder to the PATH variable. 
    
```
# Edit (or create) 
dzdo vi /usr/lib64/R/etc/Renviron.site 

# and add this to the first line:

PATH="/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/lib/rstudio-server/bin/pandoc/"
```  
    
2. Default LaTeX install on Red Hat 6.8 is from 2007 and does not include many of the needed .sty files.  
    - solution 1: The easiest way to correct this is to install LaTeX using the directions at http://www.tug.org/texlive/quickinstall.html.  A recent verison may be downloaded from http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz.  The full install takes a long time (~90 minutes).  You can spead this up by doing the basic only install and then using `tlmgr install` to get what you need.  First, update to the path were instal-tl puts your new latex install.  Defualt would be captured with:
    
```
# Edit (or create) 
dzdo vi /usr/lib64/R/etc/Renviron.site 

# and add this to the first line:

PATH="/usr/local/texlive/2016/bin/x86_64-linux:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/lib/rstudio-server/bin/pandoc/"

# Can also change this for your shell with:

export PATH=/usr/local/texlive/2016/bin/x86_64-linux:$PATH
    
```
cd /directory/for/downloads
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xvf install-tl-unx.tar.gz
cd install-tl-20161206/
./install-tl
s
e
r
i
tlmgr install inconsolata
```

