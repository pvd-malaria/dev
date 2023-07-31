# libraries ------------------------------------------------------------
library(tidyverse)
library(sf)
library(rnaturalearth)

# data ---------------------------------------------------
paises_sivep <- read_csv("sivep/sivep_paises.csv")

countries <- ne_countries(returnclass = "sf")
units <- ne_download(scale = 50, type = "map_units", returnclass = "sf")
subunits <- st_read("dados/etc/ne_10m_admin_0_scale_rank_minor_islands")

sivep <- read_rds("dados/sivep_datatable.rds")

paises_positivos <- tibble(codigos = unique(c(sivep$PAIS_INF,
                                               sivep$PAIS_RES)))

# munge ------------------------------------------------------------
# merge world with sivep countries with positive cases
paises <- paises_positivos %>%
   left_join(paises_sivep, by = c("codigos")) %>%
   filter(!is.na(iso_a2))

congo <- countries %>%
   filter(iso_a2 %in% c("CD", "CG")) %>%
   select(iso_a2) %>%
   mutate(geometry = st_union(geometry)) %>%
   filter(iso_a2 == "CD") %>%
   mutate(iso_a2 = "CD/CG",
          codigos = 50,
          paises = "Congo")

world2 <- countries %>% inner_join(paises, by = c("iso_a2")) %>%
   select(codigos, paises, iso_a2, geometry) %>%
   rbind(congo)

aj <- paises %>% anti_join(countries, by = c("iso_a2")) %>%
   filter(codigos != 50)

world3 <- filter(units, SUBUNIT %in% c("French Guiana",
                                "Saint Helena",
                                "Antigua",
                                "Anguilla",
                                "Johnston Atoll",
                                "Cayman Islands",
                                "Bermuda",
                                "Bahrain")) %>%
   mutate(codigos = c(183, 8, 39, 24, 85, 18, 9)) %>%
   select(codigos) %>%
   inner_join(aj, by = "codigos")

johnston <- subunits %>% filter(sr_subunit == "Johnston Atoll") %>%
   group_by(sr_subunit) %>%
   summarise(geometry = st_combine(geometry)) %>%
   mutate(codigos = 110) %>%
   select(codigos) %>%
   inner_join(aj, by = "codigos")

world <- rbind(world2, world3, johnston)

 # save ------------------------------------------------------------
st_write(world, "sivep/07_paises_positivos_sivep.gpkg")
