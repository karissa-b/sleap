import h5py
import numpy as np
import pandas as pd
from scipy.interpolate import interp1d
import matplotlib.pyplot as plt
from IPython import display
import time
import cv2

# Code adapted from sleap documentation:
#https://sleap.ai/notebooks/Analysis_examples.html#fill-missing-values

def read(files, interp=None):
    df_list = []
    for i in range(len(files)):
        # read in the file
        with h5py.File(files[i], "r") as x:
            Y = x["tracks"][:].T

        if interp:
            data = interpolate(Y, interp)
        else:
             data = Y
        
        head_loc = data[:,0,:,:].squeeze()

        df = pd.DataFrame(head_loc, columns=["x", "y"])
        # df["x_disp"] = df["x"].diff().abs()
        # df["y_disp"] = df["y"].diff().abs()
        # df["log_x_disp"] = np.log1p(df["x_disp"])
        # df["log_y_disp"] = np.log1p(df["y_disp"])
        df['disp'] = eucl_dist(df['x'], df['y'], df['x'].shift(), df['y'].shift())
        df['log_disp'] = np.log1p(df['disp'])
        
        df_list.append(df)

    return df_list

def interpolate(Y, kind="linear"):
    # Store initial shape.
        initial_shape = Y.shape

        # Flatten after first dim.
        Y = Y.reshape((initial_shape[0], -1))

        # Interpolate along each slice.
        for i in range(Y.shape[-1]):
            y = Y[:, i]

            # Build interpolant.
            x = np.flatnonzero(~np.isnan(y))
            f = interp1d(x, y[x], kind=kind, fill_value=np.nan, bounds_error=False)

            # Fill missing
            xq = np.flatnonzero(np.isnan(y))
            y[xq] = f(xq)
            
            # Fill leading or trailing NaNs with the nearest non-NaN values
            mask = np.isnan(y)
            y[mask] = np.interp(np.flatnonzero(mask), np.flatnonzero(~mask), y[~mask])

            # Save slice
            Y[:, i] = y

        # Restore to initial shape.
        data = Y.reshape(initial_shape)

        return data

def eucl_dist(x1, y1, x2, y2):
    return np.sqrt((x2 - x1)**2 + (y2 - y1)**2)

def count_missing(df):
     missing = np.isnan(df['x']).sum()
     return missing

def filter(df_input, threshold, filter='disp', interp='cubic'):
    df = df_input.copy()
    
    # print(f"Original: {np.isnan(df['x']).sum()}")

    df.loc[df[filter] > threshold, ['x', 'y']] = np.nan
    filtered = np.isnan(df['x']).sum()
    # print(f"Filtered: {filtered}")

    df[['x', 'y']] = interpolate(df[['x', 'y']].values, kind=interp)
    # print(f"Interpolated: {np.isnan(df['x']).sum()}")

    df['disp2'] = eucl_dist(df['x'], df['y'], df['x'].shift(), df['y'].shift())
    
    return df, filtered

# VISUALISATIONS

def vis_tracks(df, window_size=100, colour="log_x_disp"):
    x_min, x_max = np.nanmin(df['x']), np.nanmax(df['x'])
    y_min, y_max = np.nanmin(df['y']), np.nanmax(df['y'])

    for i in range(len(df) - window_size + 1):
        try:
            plt.plot(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size],
                alpha=0.25
            )

            plt.scatter(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size], 
                c=df[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )

            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)
            
            plt.show()
            time.sleep(0.05)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def vis_tracks2(df1, df2, window_size=100, names=['df1', 'df2'], colour='disp'):
    x_min, x_max = np.nanmin(pd.concat([df1['x'], df2['x']])), np.nanmax(pd.concat([df1['x'], df2['x']]))
    y_min, y_max = np.nanmin(pd.concat([df1['y'], df2['y']])), np.nanmax(pd.concat([df1['y'], df2['y']]))

    for i in range(len(df1) - window_size + 1):
        try:
            plt.figure(figsize=(14, 6))

            # Plot for df1
            plt.subplot(1, 2, 1)
            plt.plot(
                df1['x'].iloc[i:i+window_size], 
                df1['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df1['x'].iloc[i:i+window_size], 
                df1['y'].iloc[i:i+window_size], 
                c=df1[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )
            plt.title(names[0])
            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)

            # Plot for df2
            plt.subplot(1, 2, 2)
            plt.plot(
                df2['x'].iloc[i:i+window_size], 
                df2['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df2['x'].iloc[i:i+window_size], 
                df2['y'].iloc[i:i+window_size], 
                c=df2[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )
            plt.colorbar()
            plt.title(names[1])
            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)

            plt.show()
            time.sleep(0.05)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def vis_tracks3(df, window_size=100, colour="disp", title=None, delay=0.05):
    x_min, x_max = np.nanmin(df['x']), np.nanmax(df['x'])
    y_min, y_max = np.nanmin(df['y']), np.nanmax(df['y'])

    y_min2, y_max2 = np.nanmin(df['disp']), np.nanmax(df['disp'])

    for i in range(len(df) - window_size + 1):
        try:
            plt.figure(figsize=(9, 9))
            grid = plt.GridSpec(3, 1, hspace = 0.4)
            
            if title is not None:
                plt.title(title)

            plt.subplot(grid[:2, 0])
            plt.plot(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size], 
                c=df[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )
            plt.colorbar()
            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)
            
            plt.subplot(grid[2, 0])
            plt.plot(df['disp'].iloc[i:i+window_size])
            plt.ylim(y_min2, y_max2)

            plt.show()
            time.sleep(delay)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def vis_tracks_img(df, vid_path, window_size=100):
    x_min, x_max = np.nanmin(df['x']), np.nanmax(df['x'])
    y_min, y_max = np.nanmin(df['y']), np.nanmax(df['y'])

    for i in range(len(df) - window_size + 1):
        try:
            video = cv2.VideoCapture(vid_path)
            video.set(cv2.CAP_PROP_POS_FRAMES, i+window_size)
            ret, frame = video.read()

            plt.imshow(frame)

            plt.plot(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df['x'].iloc[i:i+window_size], 
                df['y'].iloc[i:i+window_size], 
                c=df['log_x_disp'].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )

            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)
            plt.show()

            time.sleep(0.05)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def vis_tracks_img2(df1, df2, vid_path, window_size=100, names=['df1', 'df2'], colour='disp'):
    x_min, x_max = np.nanmin(pd.concat([df1['x'], df2['x']])), np.nanmax(pd.concat([df1['x'], df2['x']]))
    y_min, y_max = np.nanmin(pd.concat([df1['y'], df2['y']])), np.nanmax(pd.concat([df1['y'], df2['y']]))

    for i in range(len(df1) - window_size + 1):
        try:
            plt.figure(figsize=(12, 6))

            video = cv2.VideoCapture(vid_path)
            if video is None:
                return "Video not found"
            
            video.set(cv2.CAP_PROP_POS_FRAMES, i+window_size)
            ret, frame = video.read()

            # Plot for df1
            plt.subplot(1, 2, 1)
            plt.imshow(frame, alpha = 0.5)
            plt.plot(
                df1['x'].iloc[i:i+window_size], 
                df1['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df1['x'].iloc[i:i+window_size], 
                df1['y'].iloc[i:i+window_size], 
                c=df1[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )
            plt.title(names[0])
            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)

            # Plot for df2
            plt.subplot(1, 2, 2)
            plt.imshow(frame, alpha = 0.5)
            plt.plot(
                df2['x'].iloc[i:i+window_size], 
                df2['y'].iloc[i:i+window_size],
                alpha=0.25
            )
            plt.scatter(
                df2['x'].iloc[i:i+window_size], 
                df2['y'].iloc[i:i+window_size], 
                c=df2[colour].iloc[i:i+window_size],
                cmap="viridis",
                marker="."
            )
            plt.title(names[1])
            plt.xlim(x_min, x_max)
            plt.ylim(y_min, y_max)

            plt.show()
            time.sleep(0.05)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def missing_o_time(df, window_size=1000, title="Missing values over time"):
    Y = df[["x", "y"]].values

    missing_values = []
    for i in range(0, Y.shape[0], window_size):
        window = Y[i:i+window_size, :]
        x = np.isnan(window).sum()
        missing_values.append(x)

    plt.bar(range(len(missing_values)), missing_values, color='skyblue')
    plt.xlabel("Window index")
    plt.ylabel("Number of missing values")
    plt.title(title)
    plt.show()

def disp_o_time(df, title="Displacement over time"):
    y_min, y_max = np.nanmin(df['disp']), np.nanmax(df['disp'])
    
    plt.plot(df['disp'])
    plt.ylim(y_min, y_max)
    plt.title(title)
    plt.minorticks_on()
    plt.show()

def disp_o_time2(df, window_size=100, title="Displacement over time"):
    y_min, y_max = np.nanmin(df['disp']), np.nanmax(df['disp'])
    
    for i in range(len(df) - window_size + 1):
        try:
            plt.plot(df['disp'].iloc[i:i+window_size])
            plt.ylim(y_min, y_max)
            plt.title(title)
            plt.minorticks_on()
            plt.show()

            time.sleep(0.05)
            display.clear_output(wait=True)
        except KeyboardInterrupt:
            break

def count_frames(vid_path):
    video = cv2.VideoCapture(vid_path)
    frames = video.get(cv2.CAP_PROP_FRAME_COUNT)
    return frames

def dims(vid_path):
    video = cv2.VideoCapture(vid_path)
    h = video.get(cv2.CAP_PROP_FRAME_HEIGHT)
    w = video.get(cv2.CAP_PROP_FRAME_WIDTH)
    print(h)
    print(w)