#!/bin/bash
#SBATCH --mail-user=angel.allen@adelaide.edu.au
#SBATCH --mail-type=ALL
#SBATCH -p a100                # partition (this is the queue your job will be added to)
#SBATCH -n 1              	   # number of tasks (sequential job starts 1 task) (check this if your job unexpectedly uses 2 nodes)
#SBATCH -c 4           		   # number of cores (sequential job calls a multi-thread program that uses 8 cores)
#SBATCH --time=2-00:00:00      # time allocation, which has the format (D-HH:MM), here set to 1 hour
#SBATCH --gres=gpu:1           # generic resource required (here requires 4 GPUs)
#SBATCH --mem=16GB             # specify memory required per node (here set to 16 GB)



# sleap-track $labels_path --only-suggested-frames --tracking.tracker simple -m "$ce_path" -m "$pkg_path/models/$model_name" -o $model_name"_predictions.slp"
sleap-track $labels_path --only-suggested-frames --tracking.tracker simple -m "$ce_path" -m "$pkg_path/models/$model_name" -o $model_name"_predictions.slp"