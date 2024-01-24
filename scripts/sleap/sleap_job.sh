#!/bin/bash

# Configure the resources required
#SBATCH -p a100                                           # partition (this is the queue your job will be added to)
#SBATCH -n 1              	                          # number of tasks (sequential job starts 1 task) (check this if your job unexpectedly uses 2 nodes)
#SBATCH -c 4           		                          # number of cores (sequential job calls a multi-thread program that uses 8 cores)
#SBATCH --time=2-00:00:00                                 # time allocation, which has the format (D-HH:MM), here set to 1 hour
#SBATCH --gres=gpu:1                                      # generic resource required (here requires 4 GPUs)
#SBATCH --mem=32GB                                        # specify memory required per node (here set to 16 GB)

# Directories
echo current dir: $PWD

base_dir=/hpcfs/users/$USER/adult-behaviour/sleap
pkg_dir=$base_dir/20231011-2_labels_dlc.v001.slp.training_job

echo base dir: $base_dir
echo pkg dir: $pkg_dir

# Activating environment
echo -e "\nLoading environment..."
source /hpcfs/users/a1790231/mambaforge/etc/profile.d/conda.sh
conda activate /hpcfs/users/a1790231/mambaforge/envs/sleap

env_dir=/hpcfs/users/a1790231/mambaforge/envs/sleap/lib

# Check if the new_path exists in LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$env_dir:"* ]]; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$env_dir
    echo "Added $env_dir to LD_LIBRARY_PATH"
else
    echo "$env_dir already exists in LD_LIBRARY_PATH"
fi

# Run script
echo -e "\nNavigating to $pkg_dir..."
cd $pkg_dir

#echo -e "\nBeginning training..."
#sleap-train single_instance.json labels_dlc.v001.pkg.slp

echo -e "\nPreparing for tracking..."
model_name=$(ls $pkg_dir/models)
model_dir=$pkg_dir/models/$model_name
echo Model dir: $model_dir

id=$(date '+%d%m%Y_%H%M')
echo id: $id

echo -e "\nBeginning tracking..."
sleap-track -m $model_dir -o $id"_output_predictions.slp" labels_dlc.v001.pkg.slp
