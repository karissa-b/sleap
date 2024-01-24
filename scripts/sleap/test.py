# import cv2
from glob import glob

# print(glob(f"/Users/angel/Documents/test hi/*123*/*"))
print(glob("/Users/angel/Documents/20230914_lrrk2-6m_ymaze/resources/masks/arenas/094356/arena2*.png")[0])

# v1="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 model paper/lrrk2 adult behaviour/20230914_lrrk2-G2009S-6m/videos/cropped/no_bg2/20230914T094356_no-bg2-1.avi"
# v2="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 model paper/lrrk2 adult behaviour/20230914_lrrk2-G2009S-6m/videos/no_bg1/20230914T113837_no-bg1-1.avi"
# v3="/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 model paper/lrrk2 adult behaviour/20230914_lrrk2-G2009S-6m/videos/no_bg1/20230914T094400_no-bg1-1.avi"

# def count_frames(input):
#     vid = cv2.VideoCapture(input)
#     frames = vid.get(cv2.CAP_PROP_FRAME_COUNT)
#     return frames

# for i in glob("/Users/angel/Library/CloudStorage/Box-Box/Data/lrrk2 model paper/lrrk2 adult behaviour/20230914_lrrk2-G2009S-6m/videos/cropped/no_bg1/20230914T094356*"):
#     print(f"Video: {i}, frames: {count_frames(i)}")

# # print(count_frames(v1))
# # print(count_frames(v2))
# # print(count_frames(v3))