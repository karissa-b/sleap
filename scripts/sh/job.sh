#!/bin/bash
#SBATCH --mail-user=angel.allen@adelaide.edu.au
#SBATCH --mail-type=ALL
#SBATCH -p batch        	  # partition (this is the queue your job will be added to) 
#SBATCH -N 1               	  # number of nodes
#SBATCH -n 1              	  # number of cores (sequential job => uses 1 core)
#SBATCH --time=3-00:00:00     # time allocation, which has the format (D-HH:MM:SS)
#SBATCH --mem=8GB         	  # specify the memory required per node

# Execute the program
module purge
module use /apps/skl/modules/all
module load FFmpeg/4.2.1
module load R/4.1.2

vid_dir=/hpcfs/users/$USER/videos/concatenated
base_dir=/hpcfs/users/$USER/20230914_lrrk2-6m_ymaze

# Activating environment
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

x=$(date +"%Y%m%dT%H%M")

$python3 -u $base_dir/scripts/python/video-processing.py $base_dir $vid_dir > $x"_vid-proc.log"
