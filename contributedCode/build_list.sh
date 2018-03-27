#!/usr/bin/env bash
rm index.html
echo "<html>" > index.html
echo "<body>" >> index.html
echo "<h1> US EPA Shiny Apps </h1>" >> index.html
echo "<ul>" >> index.html
for d in */ ; do
echo "<li><a href='http://edap-enviro1.rtpnc.epa.gov:3838/$d)'>$d</a></li>" >> list.html
done
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html