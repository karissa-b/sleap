#!/bin/bash
job_script=/hpcfs/users/$USER/20230914_lrrk2-6m_ymaze/scripts/sleap/inf_job.sh
sleap_base=/hpcfs/users/$USER/sleap; echo sleap_base: $sleap_base
vids_base=/hpcfs/users/$USER/videos/processed; echo vids_base: $vids_base

vid_paths=$(find $vids_base -name "*.avi" | sort) # gets full path
num_vids=$(echo $vid_paths | wc -w)
echo Found $num_vids videos.

run=$(date '+%y%m%d_%H%M')
ce_model="CE_1_231130_101949.centroid.n=843"
ci_model="CI_1_231130_101949.centered_instance.n=843"

echo -e "run: $run \nce_model: $ce_model \nci_model: $ci_model" > "$sleap_base/logs/${run}_inf_jobs.log"

for vid_path in $vid_paths; do
    sbatch -J inf_$(basename $vid_path .avi) $job_script $sleap_base $vid_path $run $ce_model $ci_model
done