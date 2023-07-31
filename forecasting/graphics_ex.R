library(fpp3)


# tsibbles ----------------------------------------------------------------

PBS

a10 <- PBS %>%
  filter(ATC2 == "A10") %>%
  select(Month, Concession, Type, Cost) %>%
  summarise(Cost = sum(Cost) / 1e6)

prison <- readr::read_csv("https://OTexts.com/fpp3/extrafiles/prison_population.csv")

prison <- prison %>%
  mutate(Quarter = yearquarter(Date),
         Date = NULL) %>%
  as_tsibble(key = c(State, Gender, Legal, Indigenous),
             index = Quarter)


# time plots --------------------------------------------------------------

melsyd_economy <- ansett %>%
  filter(Airports == "MEL-SYD", Class == "Economy") %>%
  mutate(Passengers = Passengers/1000)

autoplot(melsyd_economy, Passengers) +
  labs(title = "Ansett airlines economy class",
       subtitle = "Melbourne-Sidney",
       y = "Passengers ('000)")

autoplot(a10, Cost) +
  labs(y = "$ (millions)",
       title = "Australian antidiabetic drug sales")


# seasonal plots ----------------------------------------------------------

a10 %>%
  gg_season(Cost, labels = "both") +
  labs(y = "$ (millions)",
       title = "Seasonal plot: Antidiabetic drug sales") +
  expand_limits(x = ymd(c("1972-12-28", "1973-12-04")))


# seasonal subseries plots ------------------------------------------------

a10 %>%
  gg_subseries(Cost) +
  labs(
    y = "$ (millions)",
    title = "Australian antidiabetic drug sales"
  )


# scatterplots ------------------------------------------------------------

vic_elec %>%
  filter(year(Time) == 2014) %>%
  autoplot(Demand) +
  labs(y = "GW",
       title = "Half-hourly electricity demand: Victoria")


vic_elec %>%
  filter(year(Time) == 2014) %>%
  autoplot(Temperature) +
  labs(
    y = "Degrees Celsius",
    title = "Half-hourly temperatures: Melbourne, Australia"
  )

vic_elec %>%
  filter(year(Time) == 2014) %>%
  ggplot(aes(x = Temperature, y = Demand)) +
  geom_point() +
  labs(x = "Temperature (degrees Celsius)",
       y = "Electricity demand (GW)")


# scatterplot matrices ----------------------------------------------------

visitors <- tourism %>%
  group_by(State) %>%
  summarise(Trips = sum(Trips))

visitors %>%
  ggplot(aes(x = Quarter, y = Trips)) +
  geom_line() +
  facet_grid(vars(State), scales = "free_y") +
  labs(title = "Australian domestic tourism",
       y= "Overnight trips ('000)")


# lag plots ---------------------------------------------------------------

recent_production <- aus_production %>%
  filter(year(Quarter) >= 2000)
recent_production %>%
  gg_lag(Beer, geom = "point") +
  labs(x = "lag(Beer, k)")


# autocorrelation, ACF and PACF -------------------------------------------

recent_production %>% ACF(Beer, lag_max = 9)

