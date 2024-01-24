#!/bin/bash

cd "/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/sleap/data/231125_1448"

for file in *" .avi)"; do
    newname=$(echo "$file" | sed 's/ \.avi)$//')
    mv "$file" "$newname"
done