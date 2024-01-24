#!/bin/bash

# x="bgsub2_L_4"
# echo $x

# base_dir=/Users/angel/Documents/adult-behaviour/sleap/training

# echo $base_dir/configs/$x.json

# dataset=$(awk -F '_' '{print $1}' <<< "$x")
# echo $dataset
# pkg_path=$(find $base_dir/packages -name "$dataset*")
# echo $pkg_path
# ls $base_dir/packages

# base_dir=/Users/angel/Documents/adult-behaviour/sleap/training
# model_path=$(find $base_dir/models -name "$1*")
# echo $model_path

# [ $# -eq 0 ] && echo No args || echo yes args

# [ -z $1 ] && echo Missing experiment ID; exit
# [ -z $1 ] || echo "Config file: $1 ; does exist."

# case "$1" in !("t" | "p" | "b")) ;; esac && echo "Invalid mode" # validating mode input
# RESULT=$(echo " a b c " | grep -op " $1 ")
# echo $RESULT

# exp_id=$1; echo exp_id: $exp_id
# [ -z $exp_id ] && { echo Missing experiment ID; exit; }

# list="t p b"
# echo $list | grep -w $1

# mode=$1; echo mode: $mode
# [ -z $mode ] && { echo No mode selected, running training and prediction; mode='b'; }
# if ! [[ "$mode" =~ ^('t'|'p'|'b')$ ]]; then echo Invalid mode.; fi # validating mode input

x=(hello there world)

echo ${x[1]}
echo ${x[@]:1}

y=(4 6)
len=$(( ${y[1]} - ${y[0]} ))
echo $y
echo $len