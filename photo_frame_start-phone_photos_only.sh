#!/bin/bash

# Total number of pictures to select
# (we currently display photos for 16 hours/day and 
#  average 100 photos/hour.)
TOTALPICS=1700

# Set DEBUG to 1 for debug messages, anything else to turn off debug
DEBUG=0

FBI='/usr/bin/fbi'
FIND='/usr/bin/find'
EXCLUDESFILE='/root/photo_frame/photo_frame_excludes.txt'

# cd to the base dir of the images so the relative path is shorter
cd /mnt/wizhome/scottg/Photos/

# Set "field separater" to end of line to allow spaces and other special chars
# in filepaths
IFS=$'\n\b'
NEWL=$'\n'


# Note: keep the total number of images select below a few thousand to keep from
#       exceeding max argument length. If one is displaying 2 images per minute,
#       then only 2880 images will be displayed in 24 hours. Therefore there is 
#       no benefit to including more images than that in the list.


# Include 900 random kristi pictures
IMAGES="$(/usr/bin/find ./kristi\'s\ phone\ photos\ from\ dropbox/ \
       -iname '*.j*g' -print |/usr/bin/sort -R|/usr/bin/head -n 800)"

# Include 900 random scott pictures
IMAGES="$IMAGES $(/usr/bin/find ./iPhone_photos/ -iname '*.j*g' \
       -print |/usr/bin/sort -R|/usr/bin/head -n 800)"


[[ $DEBUG -eq 1 ]] && echo "Num of pics before removal of dups: \
  $(echo "$IMAGES" | wc -l)"

# Remove duplicate listings and randomize image list
IMAGES=$(echo "$IMAGES" | sort | uniq | sort -R | head -n $TOTALPICS)
[[ $DEBUG -eq 1 ]] && echo "Final number of pics:  $(echo "$IMAGES" | wc -l)" 
[[ $DEBUG -eq 1 ]] && exit 99

# Log IMAGES list to file:
echo "$IMAGES" > /var/log/photo_frame_image_list-$(date +%d).log

# Generate web page list of today's images
echo "<h2> $(date +'%A %F') </h2> <br>" > /usr/share/nginx/www/index.html
echo "$IMAGES" | sed 's/^\.\/\(.*\)$/<a href="Photos\/\1">\1<\/a><br>/' \
  | nl \
  | gawk '{print strftime("%H:%M - ",systime() + ($1 * 36) ),$0 ; }' \
  >> /usr/share/nginx/www/index.html

# turn on display
/usr/bin/tvservice -p
/bin/fbset -depth 8
/bin/fbset -depth 16

# fbi parms:
#  -T 1   = display on first console
#  -a     = autoscale images to display size
#  -t 30  = display each image for 30 seconds
#  -u     = randomize order of images
#  -noverbose = do not display status info at bottom of screen
#  -f 'font' = specify font to use for status info
#  -readahead = read ahead images into cache (pre-fetches next image 
#               immediately after showing current image)
#  -blend = image blend time in milliseconds

$FBI -T 1 -a -t 30 -f 'DejaVu Sans Mono-23' -readahead -blend 750 $IMAGES
