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
configs_base=/hpcfs/users/$USER/20230914_lrrk2-6m_ymaze/training_configs
sleap_base=/hpcfs/users/$USER/sleap; echo sleap_base: $sleap_base

labels=$1
config=$2
# ce_config=$2
# ci_config=$3

# Script ----------
cd $sleap_base

echo sleap-train $config $labels
sleap-train $config $labels
# echo sleap-train $ci_config $labels
# sleap-train $ci_config $labels
