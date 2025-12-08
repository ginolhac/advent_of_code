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
  mutate(across(starts_with("get_star_ts"), \(ts) as_datetime(ts))) |>
  select(-id, -starts_with("star_index")) |>
  mutate(
    ts_day1 = as_datetime(lstats$day1_ts) + days(as.integer(s_day) - 1L),
    time_solve_1 = get_star_ts_1 - ts_day1,
    time_solve_2 = get_star_ts_2 - get_star_ts_1
  ) |>
  pivot_longer(
    cols = starts_with("time_solve"),
    names_to = "part",
    names_prefix = "time_solve_",
    values_to = "timestamp"
  ) -> aoc_stats

ggplot(aoc_stats, aes(x = s_day, y = timestamp, colour = name, group = name)) +
  geom_point() +
  geom_line() +
  scale_y_continuous(
    labels = scales::label_timespan(unit = "secs"),
    breaks = seq(0, 3600 * 24, 3600 * 4),
  ) +
  facet_wrap(vars(part), labeller = "label_both") +
  theme_bw() +
  labs(
    x = "Day",
    colour = NULL,
    title = "AoC 2025",
    y = "Time to solve (Part 1: from puzzle release, Part 2: from part 1)"
  )
