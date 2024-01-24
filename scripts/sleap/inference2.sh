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
# $1: path to videos relative to the video base dir (eg. cropped/no_bg1)
# $2: model directory name (eg. "231024_200215.single_instance.n=421")

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
base_dir=/hpcfs/users/$USER/sleap/20231121_adult-ymaze
vid_path=$1
model="231122_132531.single_instance.n=274"
# model="231024_200215.single_instance.n=421"
# model="231122_130726.single_instance.n=251"
# model="231122_132531.single_instance"

# Script ----------
output_path="$base_dir/predictions/$(basename $vid_path .avi)_predictions.slp"

echo -e "\nRunning inference on $vid_path"
echo sleap-track "$vid_path" --frames 0,-161966 -m "/hpcfs/users/$USER/sleap/20231121_adult-ymaze/models/$model/training_config.json" --tracking.tracker none -o "/hpcfs/users/$USER/sleap/20231121_adult-ymaze/predictions/231122_201652_predictions.slp" --verbosity json --no-empty-frames

sleap-track "$vid_path" -m "$base_dir/models/$model" -o "$output_path"
# sleap-track "$vid_path" --frames 0,-161966 -m "/hpcfs/users/$USER/sleap/20231121_adult-ymaze/models/$model/training_config.json" --tracking.tracker none -o "/hpcfs/users/$USER/sleap/20231121_adult-ymaze/predictions/231122_201652_predictions.slp" --verbosity json --no-empty-frames
# sleap-convert --format analysis -o "$output_dir/${name%_*}.h5" "$output_path"
# Could add code from convert_slp_h5.bash to this to automatically convert files to h5?

# /hpcfs/users/a1790231/sleap/20231121_adult-ymaze/models/231122_195627.single_instance.n=274/training_config.json
# /hpcfs/users/a1790231/sleap/20231121_adult-ymaze/models/231122_132531.single_instance.n\=274/