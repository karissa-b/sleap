# Y-MAZE STATS

# This will calculate the turns from EthoVision raw data where zone transitions are recorded

calc_ymaze_stats <- function(data) {
  bins <- tibble(
    bin = c(1:18),
    max_time = seq(300, 5400, by = 300)
  )
  
  data$bin <- cut(data$time2, breaks = c(0, bins$max_time), labels = bins$bin, include.lowest = T)
  
  print(colnames(data))
  
  # Calculating turns and tetragrams
  data <- data %>%
    filter(rowSums(select(data, AB:CB), na.rm = T) == 1) %>%
    mutate(
      zone_change = names(select(., AB:CB))[max.col(select(., AB:CB))],
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
  
  print(colnames(data))
  
  # Creating summary tables
  tetragrams <- unique(data$tetragram)
  
  tet_long <- data %>%
    dplyr::select(fish_id, bin, genotype, trial, tetragram) %>%
    na.omit() %>%
    group_by(fish_id, bin) %>%
    table() %>%
    as_tibble()
  
  print(colnames(tet_long))
  print(length(tet_long))
  print(tet_long, n = 1000)
  
  tet_wide <- tet_long %>% spread(tetragram, n)
  
  print(tet_wide, n = 1000)
  
  turn_long <- data %>%
    dplyr::select(fish_id, bin, genotype, trial, turn) %>% 
    na.omit() %>% 
    group_by(fish_id, bin) %>% 
    table() %>% 
    as_tibble()
  
  turn_wide <- turn_long %>% spread(turn, n)
  
  print(colnames(tet_wide))
  
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
  
  return(final_data)
}
