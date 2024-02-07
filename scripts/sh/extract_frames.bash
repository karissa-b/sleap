#!/bin/bash

cd raw_videos/
files=`ls *.avi`

echo $files

for i in $files
do
    
    name=$(cut -d "." -f1 <<< "$(basename "$i")")
	echo $name
    ffmpeg -ss 00:00:01 -i "$i" -frames:v 1 "/Users/karissabarthelson/analyses/sleap/resources/frames/${name}_frame.jpg"

done