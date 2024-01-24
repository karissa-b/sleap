# MISSING VALUES

# This script is for identifying missing values in tracking data

# Shows the total number of missing values for every fish
sum_missing_values <- function(data, title = "Total number of missing values") {
  sum_missing_values <- data %>%
    group_by(fish_id, video) %>%
    summarise(x_missing = sum(is.na(x)),
              y_missing = sum(is.na(y))) %>%
    pivot_longer(cols = c(x_missing, y_missing), names_pattern = "(^.)", names_to = "coord", values_to = "missing")
  
  ggplot(sum_missing_values, aes(x = fish_id, y = missing, fill = coord)) +
    geom_col(position = "dodge") +
    coord_flip() +
    ggtitle(title) +
    facet_wrap(~video)
}

missing_values <- function(data, fish_to_check) {
  missing_values <- data %>%
    mutate(
      x_missing = ifelse(is.na(x), T, F),
      y_missing = ifelse(is.na(y), T, F)
    ) %>% 
    select(fish_id, time, video, x_missing, y_missing) %>%
    pivot_longer(cols = c(x_missing, y_missing), names_pattern = "(^.)", names_to = "coord", values_to = "missing") %>%
    mutate(missing = factor(missing, levels = c(TRUE, FALSE)))
  
  ggplot(missing_values[missing_values$fish_id %in% fish_to_check,], aes(x = time, y = fish_id, fill = missing)) +
    geom_tile() +
    facet_wrap(~video) +
    scale_fill_manual(values = c("TRUE" = "#F8766D", "FALSE" = "transparent"))
}