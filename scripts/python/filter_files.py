import os
import pandas as pd
import re
import sys

root = "/Users/angel/Documents"

file_dir = sys.argv[1] if len(sys.argv) > 1 else "/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 adult behaviour/lrrk2 6m Y-maze/data/processed"
base_dir = sys.argv[2] if len(sys.argv) > 2 else "/Users/angel/Documents/20230914_lrrk2-6m_ymaze"
ext = sys.argv[3] if len(sys.argv) > 3 else ""
# base_dir = sys.argv[3] if len(sys.argv) > 3 else f"/hpcfs/users/{os.getenv('USER')}/20230914_lrrk2-6m_ymaze"
# base_dir = sys.argv[3] if len(sys.argv) > 3 else f"{root}/20230914_lrrk2-6m_ymaze"

print(f"Looking for file ext {ext} in {file_dir}")

files = sorted([i for i in os.listdir(file_dir) if i.endswith(ext)])
num_files1 = len(files)
print(f"Found {num_files1} files.")

trials = pd.read_csv(f"{base_dir}/resources/metadata/trials.csv")
print(f"Trials: {trials}")

for i in trials['id']:
    trial_data = trials[trials['id'] == i]
    print(f"\nTrial: {i}\nNum fish: {trial_data.iloc[0]['fish']}")

    unfiltered = [fn for fn in files if str(i) in fn]
    print(f"Unfiltered: {len(unfiltered)}")

    fish_nums = "|".join(map(str, range(trial_data.iloc[0]['fish'])))
    pattern = f"(-[{fish_nums}])"
    print(f"Search pattern: {pattern}")

    filtered = [fn for fn in unfiltered if re.search(pattern, fn)]
    print(f"Filtered: {len(filtered)}")
    # print(*filtered, sep="\n")

    delete = [file for file in unfiltered if file not in filtered]
    
    if len(delete) > 0:
        print("Files to delete:")
        print(*delete, sep="\n")
        x = input("Delete files? (y/n): ")

        if x == 'y':
            print("Deleting files...")
            for vid in delete:
                os.remove(f"{file_dir}/{vid}")
        else: print("Skipping file deletion.")
    else: print("No files to delete.")

num_files2 = len([i for i in os.listdir(file_dir) if i.endswith(ext)])
print(f"\nRemaining number of files: {num_files2}")