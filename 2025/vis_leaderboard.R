library(tidyverse)

lstats <- jsonlite::read_json("2025/1029538.json")

pluck(lstats, "members") |>
  map(as_tibble) |>
  list_rbind() |>
  mutate(
    s = imap(completion_day_level, \(x, i) {
      enframe(x, name = "part") |>
        unnest_longer(value) |>
        mutate(day = i)
    })
  ) |>
  select(-completion_day_level) |>
  unnest(s, names_sep = '_') |>
  pivot_wider(
    id_cols = c(stars:id, s_day),
    names_from = c(s_value_id, s_part),
    values_from = s_value
  ) |>
  mutate(across(contains("ts"), as_datetime)) |>
  select(-id, -starts_with("star_index")) |>
  pivot_longer(
    cols = starts_with("get_star"),
    names_to = "part",
    names_prefix = "get_star_ts_",
    values_to = "timestamp"
  ) -> aoc_stats

ggplot(aoc_stats, aes(x = s_day, y = timestamp, colour = name, group = name)) +
  geom_point() +
  geom_line() +
  facet_wrap(vars(part), labeller = "label_both") +
  theme_bw() +
  labs(x = "Day", colour = NULL)
