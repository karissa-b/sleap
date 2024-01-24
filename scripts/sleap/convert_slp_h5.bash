#!/bin/bash

IFS=$'\n' # allows spaces in filenames

input_dir="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/sleap/predictions/20231123"
# output_dir="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/sleap/analysis_files/20231123"
output_dir="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/data/sleap"

mkdir -p $output_dir

files=($(find "$input_dir" -name "*.slp" | sort))
num_files=${#files[@]}
echo "Number of files: $num_files"

for i in ${files[@]}
do
    # echo -e "\nPath: $i"
    name=$(basename $i)
    output_path="$output_dir/${name%_*}.h5"

    if [ -f "$output_path" ]; then
        echo -e "\nFile $output_path already exists"; continue
    fi
  
    echo -e "\nConverting: $name"
    sleap-convert --format analysis -o "$output_path" "$i"
done

echo Done!