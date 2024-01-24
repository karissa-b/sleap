# Variables ----------
base_dir=/Users/angel/Library/CloudStorage/Box-Box/Data/sleap/20231121_adult-ymaze
vid_dir=$1
model="231122_132531.single_instance.n=274"
# model="231024_200215.single_instance.n=421"
# model="231122_130726.single_instance.n=251"
# model="231122_132531.single_instance"

# Script ----------
output_path="$base_dir/predictions/$(basename $vid_path .avi)_predictions.slp"

for i in $(ls $vid_dir)
do
    echo -e "\nRunning inference on $vid_path"
    echo sleap-track "$vid_path" -m "$base_dir/models/$model" -o "$output_path"
    sleap-track "$vid_dir/$i" -m "$base_dir/models/$model" -o "$output_path"
done