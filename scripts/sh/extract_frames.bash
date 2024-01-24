#!/bin/bash

vid_dir=$1

for i in $(ls "$vid_dir")
do
    name=$(cut -d "." -f1 <<< "$(basename "$i")")
	ffmpeg -ss 00:00:01 -i "$i" -frames:v 1 "resources/frames/${name}_frame.jpg"
done