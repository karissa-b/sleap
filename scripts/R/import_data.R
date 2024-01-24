# IMPORT DATA

# The data for each video analysed is put in a separate file
# Data for each arena is in a separate sheet

# The function takes a dataframe with trial metadata
# It should include: filename, trialnum, vidnum
# Assumes raw data files are in the "raw_data" directory

import_data <- function(trials, base_path) {
  cols <- c("time", "-", "x", "y", "area", "area_change", "elongation", "AB", "AC", "BA", "BC", "CA", "CB", "-")
  
  list1 <- vector("list", nrow(trials))
  for (i in 1:nrow(trials)) {
    list2 <- vector("list", 8)
    print(paste0("Reading file: ", trials$filename[i]))
    for (j in 1:8) {
      print(paste0("Reading sheet: ", j))
      x <- read_excel(file.path(base_path, trials$filename[i]), sheet = j, col_names = cols, skip = 34) %>%
        select(!starts_with("-")) %>%
        mutate(across(everything(), as.numeric)) %>%
        mutate(
          arena = j,
          trial = trials$trialnum[i],
          video = trials$vidnum[i]
        )
      list2[[j]] <- x
    }
    list1[[i]] <- do.call(rbind, list2)
  }
  data <- do.call(rbind, list1)
  return(data)
}