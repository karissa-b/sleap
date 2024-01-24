#!/bin/bash
#SBATCH --mail-user=angel.allen@adelaide.edu.au
#SBATCH --mail-type=ALL
#SBATCH -p a100                # partition (this is the queue your job will be added to)
#SBATCH -n 1              	   # number of tasks (sequential job starts 1 task) (check this if your job unexpectedly uses 2 nodes)
#SBATCH -c 4           		   # number of cores (sequential job calls a multi-thread program that uses 8 cores)
#SBATCH --time=2-00:00:00      # time allocation, which has the format (D-HH:MM), here set to 1 hour
#SBATCH --gres=gpu:1           # generic resource required (here requires 4 GPUs)
#SBATCH --mem=16GB             # specify memory required per node (here set to 16 GB)

# Arguments ----------
# $1: full path to videos
# $2: full path to model directory
# $3: full path of the project base directory

# Activating environment ----------
echo -e "\nLoading environment..."
source /hpcfs/users/$USER/mambaforge/etc/profile.d/conda.sh
env_path=/hpcfs/users/$USER/mambaforge/envs/sleap
conda activate $env_path

python3=$env_path/bin/python3
src_dir=$env_path/lib

# Check if the new_path exists in LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$src_dir:"* ]]; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$src_dir
    echo "Added $src_dir to LD_LIBRARY_PATH"
else
    echo "$src_dir already exists in LD_LIBRARY_PATH"
fi
# --------------------

# Variables ----------
base_dir=/hpcfs/users/$USER/adult-behaviour/sleap

vid_path=$1
model_path=$2
proj_dir=$3

# Script ----------
# x=$(date +"%Y%m%dT%H%M")
mkdir -p "$proj_dir/predictions"

echo -e "\nRunning inference..."
echo sleap-track -m "$model_path" -o "$proj_dir/predictions/$(basename $vid_path .avi)_predictions.slp" "$vid_path"
sleap-track -m "$model_path" -o "$proj_dir/predictions/$(basename $vid_path .avi)_predictions.slp" "$vid_path"

# Could add code from convert_slp_h5.bash to this to automatically convert files to h5?