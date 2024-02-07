from typing import ValuesView
import cv2
import glob
import numpy as np
import pandas as pd
import os
import re
import sys
from tqdm import tqdm
 

base_dir = "/Users/karissabarthelson/analyses/sleap"
input_dir = "/Users/karissabarthelson/analyses/sleap/raw_videos"

bg_dir = f"{base_dir}/resources/backgrounds"
arenas_dir = f"{base_dir}/resources/masks/arenas"
data_dir = f"{base_dir}/data/centroid"
output_dir = f"{os.path.dirname(input_dir)}/processed"

# Making directories
os.makedirs(output_dir, exist_ok=True)
os.makedirs(data_dir, exist_ok=True)

# Finding videos
vid_paths = np.sort(glob.glob(f"{input_dir}/*.avi"))
print(f"Found {len(vid_paths)} videos.")


# Checking directories
print(f"base_dir: {base_dir}")
print(f"input_dir: {input_dir}")
print(f"bg_dir: {bg_dir}")
print(f"arenas_dir: {arenas_dir}")
print(f"data_dir: {data_dir}")
print(f"output_dir: {output_dir}")
print("videos:")
print(*vid_paths, sep="\n")

t_val = 35 # thresholding value
arena_rotations = [0, None, 2, 2, 0, 0, 1, 2]

 ## FUNCTIONS

def get_arenas(vid_path, arenas_dir):

    name = re.search("(?<=T)\d+", vid_path).group(0)
    print(name)
    arena_dirs = np.sort(glob.glob(f"{arenas_dir}/*{name}*"))
    print(arena_dirs)
    
    arenas = {}
    for i, dir in enumerate(arena_dirs):
        
        arena_files = glob.glob(f"{dir}/arena* #*.png")
        print(f"Arena files: {arena_files} ")

        if not arena_files:
            print(f"No arena files found in directory: {dir}")
            continue  # Skip to the next directory

        # Ensure we find exactly 8 arena files
        if len(arena_files) != 8:
            print(f"Warning: Expected 8 arena files but found {len(arena_files)} in {dir}")

        for j, arena_file in enumerate(arena_files):

            # Extract arena number from filename
            arena_num_str = arena_file.split("arena")[-1].split(".")[0].split()[0]
            arena_num = int(arena_num_str)

            # Read the image in grayscale
            image = cv2.imread(arena_file, cv2.IMREAD_GRAYSCALE)

            if image is None:
                print(f"Failed to read arena image: {arena_file}")
                continue  # Skip to the next file

            arenas[arena_num] = image

    return arenas


def calc_background(vid_path, history=3700):
    vid = cv2.VideoCapture(vid_path)
    vid.set(cv2.CAP_PROP_POS_FRAMES, 10)

    # Taking a frame to get the dimensions for the background
    ret, frame = vid.read()
    h,w,d = frame.shape
    bg = np.zeros((h,w), np.float32)

    for i in range(history):
        ret, frame = vid.read()
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        bg = bg + frame
    bg = bg/history
    
    return bg

def crop_rotate(frame, mask, rotation):
    norm = cv2.normalize(frame, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)
    masked = cv2.bitwise_and(norm, mask)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    y_contour = contours[0]
    x, y, w, h = cv2.boundingRect(y_contour)
    cropped = masked[y:y+h, x:x+w]
    if rotation is not None:
        rotated = cv2.rotate(cropped, rotation)
    else: rotated = cropped.copy()

    return rotated


# Get arena data
arenas = [get_arenas(i, arenas_dir) for i in vid_paths]
print(f"Loaded arena masks for {len(arenas)} videos.")
print(f"{len(arenas)} arenas per video.")

# Process videos
for i, vid_path in enumerate(vid_paths):
    vid_name = re.search("(?<=T)\d+", vid_path).group(0)
    print(f"\nProcessing video: {vid_name}")
    
    bg_path = f"{bg_dir}/{vid_name}_bg-blur.bmp"

    if os.path.isfile(bg_path) == False:
        print("Calculating background...")
        bg = calc_background(vid_paths[i])
        bg_blur = cv2.GaussianBlur(bg, (7, 7), 0)
        print(f"Done. Saving background to: {bg_path}")
        cv2.imwrite(f"{bg_path}", bg_blur)
    else:
        print(f"Reading average background from: {bg_path}")
        bg_blur = cv2.imread(bg_path, cv2.IMREAD_GRAYSCALE).astype(np.float32)

    # Output videos
    vid_arenas = arenas[i]
    fourcc = cv2.VideoWriter_fourcc(*'FFV1') # codec
    
    # 30 fps, (height,width)
    outputs = [cv2.VideoWriter(f"{output_dir}/{vid_name}-{i}.avi", fourcc, 30.0, (212, 185)) for i in range(len(vid_arenas))]

    print("Loading video capture.")
    vid = cv2.VideoCapture(vid_path)
    video_length = int(vid.get(cv2.CAP_PROP_FRAME_COUNT))

    print("Starting video loop...")
    pbar = tqdm(total=video_length)
    data = {i: [] for i in vid_arenas}
    while True:
        index = vid.get(cv2.CAP_PROP_POS_FRAMES)
        ret, frame = vid.read()
        # Stop the loop when video ends
        if not ret:
            break
        pbar.update(1)

        # Convert to grayscale and blur
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        blur = cv2.GaussianBlur(frame, (7, 7), 0)

        # Calculate the difference to the background
        sub = blur - bg_blur # this will be used for the output video
        sub_norm = cv2.normalize(sub, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)
        mid = 0.8 # higher value = higher brightness
        gamma = np.log(mid*255)/np.log(np.mean(sub_norm))
        adj = np.power(sub_norm, gamma).clip(0,255).astype(np.uint8)

        diff = np.abs(sub)
        norm = cv2.normalize(diff, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)

        _, thresh = cv2.threshold(norm, t_val, 255, cv2.THRESH_BINARY)

        for i, mask in enumerate(vid_arenas.values()):
            r = arena_rotations[i]
            sub_proc = crop_rotate(adj, mask, r) # video
            thresh_proc = crop_rotate(thresh, mask, r) # data
            
            # Write the processed frame to video file
            outputs[i].write(cv2.cvtColor(sub_proc, cv2.COLOR_GRAY2BGR))
            
            # Get fish contours
            # contours, _ = cv2.findContours(thresh_proc, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            # if len(contours) > 0:
            #     areas = [cv2.contourArea(i) for i in contours]
            #     fish = contours[np.argmax(areas)]

            #     # Record coordinate data
            #     A = cv2.contourArea(fish)
            #     M = cv2.moments(fish)
            #     if M["m00"] != 0:
            #         cX = int(M["m10"] / M["m00"])
            #         cY = int(M["m01"] / M["m00"])
            #     data[i].append([index, cX, cY, A])
            # else: data[i].append([index, None, None, None])

    pbar.close()

    print("writing data to .csv files...")
    for i in vid_arenas:
        df = pd.DataFrame(data[i], columns = ["index", "x", "y", "area"])
        df.to_csv(f"{data_dir}/{vid_name}-{i}.csv", index = False)
