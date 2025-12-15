library(tidyverse)
library(httr2)

#jsonlite::read_json("2025/1029538.json")
# Tanguy 752300

lstats <- request(
  "https://adventofcode.com/2025/leaderboard/private/view/1029538.json"
) |>
  req_cookies_set(session = Sys.getenv("AOC_COOKIE")) |>
  req_perform() |>
  resp_body_json()

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
    id_cols = c(stars, name, local_score, s_day),
    names_from = c(s_value_id, s_part),
    values_from = s_value
  ) |>
  mutate(across(starts_with("get_star_ts"), \(ts) as_datetime(ts))) |>
  select(-starts_with("star_index")) |>
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

ggplot(
  aoc_stats,
  aes(
    x = fct_reorder(s_day, as.integer(s_day)),
    y = timestamp,
    colour = name,
    group = name
  )
) +
  geom_point() +
  geom_line() +
  scale_y_continuous(
    labels = scales::label_timespan(unit = "secs"),
    breaks = seq(0, 3600 * 46, 3600 * 10),
  ) +
  facet_wrap(vars(part), labeller = "label_both") +
  theme_bw() +
  labs(
    x = "Day",
    colour = NULL,
    title = "AoC 2025",
    y = "Time to solve (Part 1: from puzzle release, Part 2: from part 1)"
  )

aoc_stats |>
  filter(str_detect(name, "Cyrille|Hugues")) |>
  select(name, s_day, part, timestamp) |>
  pivot_wider(
    id_cols = c(part, s_day),
    names_from = name,
    values_from = timestamp
  ) |>
  mutate(diff_esc = `Hugues Esc_` - `Cyrille Medard de Chardon`) |>
  ggplot(aes(
    x = fct_reorder(s_day, as.integer(s_day)),
    y = diff_esc,
    colour = part,
    group = part
  )) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_y_continuous(
    labels = scales::label_timespan(unit = "secs"),
    breaks = seq(-3600 * 3, 3600 * 3, 3600),
  ) +
  coord_cartesian(ylim = c(-22000, 22000)) +
  theme_bw() +
  labs(
    x = "Day",
    colour = "Part",
    title = "AoC 2025",
    y = "difference Hugues / Cyrille time to solve"
  )
