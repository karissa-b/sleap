# RAW DATA PROCESSING
# -------------------
# Script for importing data obtained from EthoVision and processing it to get tetragram frequencies

# PACKAGES -------------------------------------------------------------------
library(tidyverse)
library(readxl)

# IMPORT ---------------------------------------------------------------------

# This helps map the file names to their trial and video number
trials <- tibble(
  filename = grep("Raw data", dir("raw_data"), value = T),
  trialnum = rep(c("1.1", "1.2", "2.1", "2.2", "3.1", "3.2"), each = 3),
  vidnum = rep(c(1:3), times = 6)
)
# Column names
cols <- c("time", "x", "x", "x", "x", "x", "x", "AB", "AC", "BA", "BC", "CA", "CB", "x")

# Metadata with fish_id
meta <- read_csv("metadata.csv", col_types = "ff-") %>%
  mutate(
    trial = c(rep(c("1.1", "1.2", "2.1", "2.2"), each = 8), rep("3.1", 5), rep("3.2", 4)),
    sheet = c(rep(c(1:8), 4), 1:5, 1:4)
  )
head(meta)

# Raw data
list1 <- vector("list", nrow(trials))
for (i in 1:nrow(trials)) {
  list2 <- vector("list", 8)
  print(paste0("Reading file: ", trials$filename[i]))
  for (j in 1:8) {
    print(paste0("Reading trial: ", j))
    x <- read_excel(paste0("raw_data/", trials$filename[i]), sheet = j, col_names = cols, skip = 33) %>%
      select(!starts_with("x")) %>%
      mutate(across(everything(), as.numeric)) %>%
      mutate(
        sheet = j,
        trial = trials$trialnum[i],
        video = trials$vidnum[i]
      )
    list2[[j]] <- x
  }
  list1[[i]] <- do.call(rbind, list2)
}
data <- do.call(rbind, list1) %>%
  left_join(meta, by = c("trial", "sheet")) %>%
  select(-sheet) %>%
  mutate(across(c(trial, video), as.factor)) %>%
  drop_na(fish_id)

# Saving the amalgamated data
write_csv(data, "processed_data/all_raw_data.csv")
write_rds(data, "processed_data/all_raw_data.rds")

head(data)

# PROCESSING -----------------------------------------------------------------

# Adding time bins
## First calculating the trial time from video time
times <- data %>%
  group_by(trial, video) %>%
  summarise(max_time = max(time)) %>%
  mutate(
    max_time2 = cumsum(max_time),
    base_time = lag(max_time2, default = 0)
  ) %>%
  ungroup()

data <- left_join(data, times[,c("trial", "video", "base_time")], by = c("trial", "video")) %>%
  mutate(time2 = base_time + time)

## Then assigning rows to 5 min time bins
bins <- tibble(
  bin = c(1:18),
  max_time = seq(300, 5400, by = 300)
)

data$bin <- cut(data$time2, breaks = c(0, bins$max_time), labels = bins$bin, include.lowest = T)

# Calculating turns and tetragrams
data <- data %>%
  filter(rowSums(data[,2:7], na.rm = T) == 1) %>%
  mutate(
    zone_change = names(.[,2:7])[max.col(.[,2:7])],
    turn = case_when(
      zone_change == "AB" ~ "R",
      zone_change == "AC" ~ "L",
      zone_change == "BA" ~ "L",
      zone_change == "BC" ~ "R",
      zone_change == "CA" ~ "R",
      zone_change == "CB" ~ "L",
    ),
    tetragram = str_c(turn, lead(turn), lead(turn,2), lead(turn,3))
  )

# Creating summary tables
tetragrams <- unique(data$tetragram)

tet_long <- data %>%
  select(fish_id, bin, tetragram) %>%
  na.omit() %>%
  group_by(fish_id, bin) %>%
  table() %>%
  as.tibble()

tet_wide <- tet_long %>% spread(tetragram, n)

turn_long <- data %>%
  dplyr::select(fish_id, bin, turn) %>% 
  na.omit() %>% 
  group_by(fish_id, bin) %>% 
  table() %>% 
  as.tibble()

turn_wide <- turn_long %>% spread(turn, n)

# Merging for final processed data
final_data <- tet_wide %>% 
  left_join(turn_wide, by = c("fish_id", "bin")) %>% 
  mutate(total_turns = L + R,
         reps = LLLL + RRRR,
         alts = RLRL + LRLR,
         rel_reps = (reps*100)/total_turns,
         rel_alts = (alts*100)/total_turns,
         rel_R = (R*100)/total_turns,
         rel_L = (L*100)/total_turns)

write_csv(final_data, "processed_data/final_data.csv")
