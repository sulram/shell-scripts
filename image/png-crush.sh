#!/bin/sh
#
# Optimizes PNG files by removing color profile metadata chunks
# Usage: ./png-crush.sh <directory>
# Example: ./png-crush.sh /path/to/images

for png in `find $1 -name *.png`;
do
	echo "crushing $png"
	pngcrush -rem cHRM -rem gAMA -rem iCCP -rem sRGB "$png" temp.png
	mv -f temp.png $png
done;