#!/usr/bin/env bash
# This only runs at boot time and decides whether the photo frame display should 
# be started or not. 

# If the time of the day is START_TIME or later AND before STOP_TIME by at 
# least MIN_RUN_MINS minutes,  then start, else run the stop script (primarly 
# just to turn off the monitor).  We only start if the current time is at least 
# MIN_RUN_MINS minutes before STOP_TIME - this eliminates the "race condition" 
# of starting photo selection just before "stop time" and having the "stop" 
# script run while photo selection is # still in progress.  Besides, why go to 
# all the effort to select a bunch of photos, if we would only have time to 
# display a handful before stopping?

# Note that START_TIME here should correspond with the times that cron is 
# starting and STOP_TIME should correstond with the times that cron is 
# stopping the photo frame. 

# Note: If time starts with a leading zero, bash wants to interpret it as
# octal. So, for example, a time of "0900" (which is not a valid octal number)
# causes problems.  To prevent this, the time is forced to be interpreted as 
# decimal in the comparisons by prefixing the variable with '10#'.

START_TIME='0600'
STOP_TIME='2200'
# only start if the current time is at least this many minutes before STOP_TIME:
MIN_RUN_MINS='15'

TIME=$(date +%H%M)

# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
# (readlink is used to expand a possible relative path to an
#  absolute path)
MYDIR="$(readlink -f ${0%/*})"

echo -n "$(date +%F-%T) - We rebooted! Time is $TIME, so "

# compute the time MIN_RUN_MINS before STOP_TIME
START_BEFORE_TIME="$(date +%H%M --date "$STOP_TIME - $MIN_RUN_MINS minutes")"

if [[ 10#$TIME -ge 10#$START_TIME && 10#$TIME -lt 10#$START_BEFORE_TIME ]]; then
  echo "photo frame is starting..."
  $MYDIR/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "photo frame is NOT starting..."
  # run the "stop" script to turn off the display
  $MYDIR/photo_frame_stop.sh 2>&1 >> /var/log/photo_frame.log
fi
