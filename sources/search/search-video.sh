#!/usr/bin/env bash

# Only implemented thing so far: video "search"

search="$1"
mydata_root=/volume1/cschuyle
video_root="$mydata_root/Noncloud-Data/video"
cd "$video_root"
ls -d */*|grep -i "$search"
