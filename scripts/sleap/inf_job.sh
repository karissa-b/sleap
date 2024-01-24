#!/bin/bash
#SBATCH --mail-user=angel.allen@adelaide.edu.au
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%x.%j.out
#SBATCH -p a100                # partition (this is the queue your job will be added to)
#SBATCH -n 1              	   # number of tasks (sequential job starts 1 task) (check this if your job unexpectedly uses 2 nodes)
#SBATCH -c 4           		   # number of cores (sequential job calls a multi-thread program that uses 8 cores)
#SBATCH --time=0-04:00:00
#SBATCH --gres=gpu:1
#SBATCH --mem=8GB

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

# Variables ----------

sleap_base=$1
vid_path=$2
run=$3
ce_model=$4
ci_model=$5

vid_id=$(basename $vid_path .avi)

# Script ----------
echo Navigating to $sleap_base
cd $sleap_base

## Inference
echo Predictions output dir: predictions/$run
[ ! -d "predictions/$run" ] && (mkdir -p "predictions/$run" && echo Creating dir "predictions/$run")
output_path="predictions/$run/${vid_id}_predictions.slp"

echo -e "\nRunning inference on $vid_path"
echo sleap-track "$vid_path" --no-empty-frames --max_instances 1 -m "models/$ce_model" -m "models/$ci_model" -o "$output_path"
sleap-track "$vid_path" --no-empty-frames --max_instances 1 -m "models/$ce_model" -m "models/$ci_model" -o "$output_path"
echo Inference complete.

# Data conversion
echo Analysis data output dir: data/$run
[ ! -d "data/$run" ] && (mkdir -p "data/$run" && echo Creating dir "data/$run")

echo -e "\nConverting data to analysis format..."
echo sleap-convert "$output_path" --format analysis -o "data/$run/$vid_id"
sleap-convert "$output_path" --format analysis -o "data/$run/$vid_id"
echo Done!
