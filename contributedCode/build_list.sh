#!/usr/bin/env bash
rm list.html
echo "<h1> US EPA Shiny Apps </h1>" > list.html
echo "<ul>" >> list.html
for d in */ ; do
echo "<li><a href='http://edap-enviro1.rtpnc.epa.gov:3838/$d)'>$d</a></li>" >> list.html
done
echo "</ul>"

