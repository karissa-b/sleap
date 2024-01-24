#!/bin/bash

IFS=$'\n'

configs_dir=/hpcfs/users/$USER/20230914_lrrk2-6m_ymaze/training_configs
sleap_base=/hpcfs/users/$USER/sleap

# configs_dir=/Users/angel/Documents/20230914_lrrk2-6m_ymaze/training_configs
# sleap_base="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/sleap"
# pkg_base="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/sleap/packages"

# labels=$sleap_base/packages/"231128_1824_labels.pkg.slp"
labels=$sleap_base/packages/"231130.20231122_labels.slp"

configs=$(ls $configs_dir/*.json)
num_configs=$(echo $configs | wc -w)
echo Found $num_configs config files.

echo Enter 'y' to submit training jobs for $num_configs config files, or "enter" to cancel:; read input

count=0
if [[ $input = 'y' ]]; then
    # run=$(date '+%y%m%d_%H%M'); echo run id: $run
    for config in $configs
    do
        name=$(basename $config .json)
        echo Submitting job $name
        echo sbatch -J $name scripts/sleap/train_job.sh "$labels" "$config"
        sbatch -J $name scripts/sleap/train_job.sh "$labels" "$config"
    done
else
    echo Exiting.
fi
