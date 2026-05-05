dir.create("data")

***************
install.packages(c(
  "tidyverse",
  "readxl",
  "countrycode",
  "janitor",
  "fixest",
  "plm",
  "modelsummary"
))

*******
  
  # Set your working directory to your project folder
  
  setwd("C:/Users/user/Downloads/RStudio/climate_migration")  # adjust path if different
******
  setwd("C:/Users/user/OneDrive/Desktop/climate_migration")


setwd("C:/Users/user/OneDrive/Desktop/climate_migration")
list.files("data/")


# Get all data files in the main project folder
files_to_move <- list.files(
  path = "C:/Users/user/OneDrive/Desktop/climate_migration",
  pattern = "\\.xlsx|\\.csv",
  full.names = TRUE
)

# Move them into data/ folder
file.copy(from = files_to_move, to = "data/")

list.files("data/")

******
  
  library(tidyverse)
library(readxl)
library(janitor)

# 1. IDMC
idmc_raw <- read_excel("data/IDMC_GIDD_Disasters_Internal_Displacement_Data.xlsx")
names(idmc_raw)

# 2. EM-DAT
emdat_raw <- read_excel("data/public_emdat_custom_request_2026-05-03_ce4b6d73-afb8-4d24-b763-76a72f199d6a.xlsx")
names(emdat_raw)

# 3. WDI
wdi_raw <- read_csv("data/27f26373-6ed1-4c63-8705-7396035d1cc6_Data.csv")
names(wdi_raw)

# 4. WGI
wgi_raw <- read_csv("data/8855dcc3-8e82-4347-a6d1-bcad3ee3b2b0_Data.csv")
names(wgi_raw)

# 5. UCDP
ucdp_raw <- read_csv("data/UcdpPrioConflict_v25_1.csv")
names(ucdp_raw)

*******
  names(idmc_raw)
names(emdat_raw)
names(wdi_raw)
names(wgi_raw)

****
  names(idmc_raw)
  
names(emdat_raw)
names(wdi_raw)
names(wdi_raw)
names(wgi_raw)
names(idmc_raw)
names(idmc_raw)
names(emdat_raw)
names(wdi_raw)
names(wgi_raw)

# ============================================
# STEP 1: CLEAN IDMC (Dependent Variable)
# ============================================

idmc <- idmc_raw %>%
  clean_names() %>%
  select(iso3, year, disaster_internal_displacements) %>%
  rename(displacement = disaster_internal_displacements) %>%
  mutate(
    year = as.integer(year),
    displacement = as.numeric(displacement),
    log_displacement = log1p(displacement)
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  group_by(iso3, year) %>%
  summarise(
    displacement = sum(displacement, na.rm = TRUE),
    log_displacement = log1p(sum(displacement, na.rm = TRUE)),
    .groups = "drop"
  )

# ============================================
# STEP 2: CLEAN EM-DAT (Climate Variables)
# ============================================

emdat <- emdat_raw %>%
  clean_names() %>%
  rename(
    iso3 = iso,
    year = start_year
  ) %>%
  filter(disaster_type %in% c("Flood", "Drought")) %>%
  filter(year >= 2008, year <= 2024) %>%
  group_by(iso3, year) %>%
  summarise(
    flood_events   = sum(disaster_type == "Flood"),
    drought_events = sum(disaster_type == "Drought"),
    total_affected = sum(as.numeric(total_affected), na.rm = TRUE),
    total_deaths   = sum(as.numeric(total_deaths), na.rm = TRUE),
    .groups = "drop"
  )

# ============================================
# STEP 3: CLEAN WDI (Control Variables)
# ============================================

wdi <- wdi_raw %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code, 
    values_from = value,
    values_fn = mean        # ← fixes the duplicate error
  ) %>%
  rename(
    iso3       = country_code,
    gdp_pc     = `NY.GDP.PCAP.KD`,
    population = `SP.POP.TOTL`,
    urban_rate = `SP.URB.TOTL.IN.ZS`
  ) %>%
  mutate(
    log_gdp_pc = log(gdp_pc),
    log_pop    = log(population)
  )

# ============================================
# STEP 4: CLEAN WGI (Governance)
# ============================================

wgi <- wgi_raw %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code, 
    values_from = value,
    values_fn = mean        # ← fixes the duplicate error
  ) %>%
  rename(
    iso3       = country_code,
    governance = `PV.EST`
  ) %>%
  select(iso3, year, governance)
unique(wgi_raw$`Series Code`)

unique(wdi_raw$`Series Code`)
# Swap the files
wdi_real <- wgi_raw   # this actually has GDP, population, urbanization
wgi_real <- wdi_raw   # this actually has governance

# ============================================
# STEP 3: CLEAN WDI (Control Variables)
# ============================================

wdi <- wdi_real %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code,
    values_from = value,
    values_fn = mean
  ) %>%
  rename(
    iso3       = country_code,
    gdp_pc     = `NY.GDP.PCAP.KD`,
    population = `SP.POP.TOTL`,
    urban_rate = `SP.URB.TOTL.IN.ZS`
  ) %>%
  mutate(
    log_gdp_pc = log(gdp_pc),
    log_pop    = log(population)
  )

# ============================================
# STEP 4: CLEAN WGI (Governance)
# ============================================

# Swap the files
wdi_real <- wgi_raw   # this actually has GDP, population, urbanization
wgi_real <- wdi_raw   # this actually has governance

# ============================================
# STEP 3: CLEAN WDI (Control Variables)
# ============================================

wdi <- wdi_real %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code,
    values_from = value,
    values_fn = mean
  ) %>%
  rename(
    iso3       = country_code,
    gdp_pc     = `NY.GDP.PCAP.KD`,
    population = `SP.POP.TOTL`,
    urban_rate = `SP.URB.TOTL.IN.ZS`
  ) %>%
  mutate(
    log_gdp_pc = log(gdp_pc),
    log_pop    = log(population)
  )

# ============================================
# STEP 4: CLEAN WGI (Governance)
# ============================================

wgi <- wgi_real %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code,
    values_from = value,
    values_fn = mean
  ) %>%
  rename(
    iso3       = country_code,
    governance = `GOV_WGI_CC.EST`
  ) %>%
  select(iso3, year, governance)




Q

# Exit any debug mode first
options(error = NULL)

# ============================================
# RELOAD RAW FILES
# ============================================

library(tidyverse)
library(readxl)
library(janitor)
library(countrycode)

idmc_raw <- read_excel("data/IDMC_GIDD_Disasters_Internal_Displacement_Data.xlsx")
emdat_raw <- read_excel("data/public_emdat_custom_request_2026-05-03_ce4b6d73-afb8-4d24-b763-76a72f199d6a.xlsx")
wdi_raw <- read_csv("data/27f26373-6ed1-4c63-8705-7396035d1cc6_Data.csv")
wgi_raw <- read_csv("data/8855dcc3-8e82-4347-a6d1-bcad3ee3b2b0_Data.csv")
ucdp_raw <- read_csv("data/UcdpPrioConflict_v25_1.csv")

# Swap files (they were downloaded in reverse)
wdi_real <- wgi_raw   # has GDP, population, urbanization
wgi_real <- wdi_raw   # has governance

# ============================================
# STEP 1: CLEAN IDMC
# ============================================

idmc <- idmc_raw %>%
  clean_names() %>%
  select(iso3, year, disaster_internal_displacements) %>%
  rename(displacement = disaster_internal_displacements) %>%
  mutate(
    year = as.integer(year),
    displacement = as.numeric(displacement),
    log_displacement = log1p(displacement)
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  group_by(iso3, year) %>%
  summarise(
    displacement = sum(displacement, na.rm = TRUE),
    log_displacement = log1p(sum(displacement, na.rm = TRUE)),
    .groups = "drop"
  )

# ============================================
# STEP 2: CLEAN EM-DAT
# ============================================

emdat <- emdat_raw %>%
  clean_names() %>%
  rename(
    iso3 = iso,
    year = start_year
  ) %>%
  filter(disaster_type %in% c("Flood", "Drought")) %>%
  filter(year >= 2008, year <= 2024) %>%
  group_by(iso3, year) %>%
  summarise(
    flood_events   = sum(disaster_type == "Flood"),
    drought_events = sum(disaster_type == "Drought"),
    total_affected = sum(as.numeric(total_affected), na.rm = TRUE),
    total_deaths   = sum(as.numeric(total_deaths), na.rm = TRUE),
    .groups = "drop"
  )

# ============================================
# STEP 3: CLEAN WDI
# ============================================

wdi <- wdi_real %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code,
    values_from = value,
    values_fn = mean
  ) %>%
  rename(
    iso3       = country_code,
    gdp_pc     = `NY.GDP.PCAP.KD`,
    population = `SP.POP.TOTL`,
    urban_rate = `SP.URB.TOTL.IN.ZS`
  ) %>%
  mutate(
    log_gdp_pc = log(gdp_pc),
    log_pop    = log(population)
  )

# ============================================
# STEP 4: CLEAN WGI
# ============================================

wgi <- wgi_real %>%
  clean_names() %>%
  select(country_code, series_code, starts_with("x")) %>%
  pivot_longer(
    cols = starts_with("x"),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(str_extract(year, "\\d{4}")),
    value = as.numeric(na_if(value, ".."))
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  pivot_wider(
    names_from = series_code,
    values_from = value,
    values_fn = mean
  ) %>%
  rename(
    iso3       = country_code,
    governance = `GOV_WGI_CC.EST`
  ) %>%
  select(iso3, year, governance)

# ============================================
# STEP 5: CLEAN UCDP
# ============================================

ucdp <- ucdp_raw %>%
  clean_names() %>%
  mutate(
    iso3 = countrycode(location, origin = "country.name", destination = "iso3c"),
    year = as.integer(year)
  ) %>%
  filter(year >= 2008, year <= 2024) %>%
  group_by(iso3, year) %>%
  summarise(
    conflict = as.integer(n() > 0),
    .groups = "drop"
  )

# ============================================
# STEP 6: MERGE ALL
# ============================================

panel_df <- idmc %>%
  left_join(emdat, by = c("iso3", "year")) %>%
  left_join(wdi,   by = c("iso3", "year")) %>%
  left_join(wgi,   by = c("iso3", "year")) %>%
  left_join(ucdp,  by = c("iso3", "year")) %>%
  replace_na(list(
    flood_events   = 0,
    drought_events = 0,
    conflict       = 0
  )) %>%
  filter(!is.na(iso3))

# ============================================
# STEP 7: CHECK
# ============================================

glimpse(panel_df)
nrow(panel_df)
colSums(is.na(panel_df))

********************

library(fixest)
library(modelsummary)

# Drop the stray NA column
panel_df <- panel_df %>% select(-`NA`)
********
  # Remove NA column safely
  panel_df <- panel_df %>% select(where(~ !all(is.na(.)))) 
Q
panel_df <- panel_df[ , !is.na(names(panel_df))]

names(panel_df)
# ============================================
# MODELS
# ============================================
# Model 1: Baseline
library(fixest)

# Model 1: Baseline
m1 <- feols(
  log_displacement ~ flood_events + drought_events,
  data = panel_df,
  cluster = ~iso3
)

# Model 2: Add controls
m2 <- feols(
  log_displacement ~ flood_events + drought_events + 
    log_gdp_pc + log_pop + urban_rate + governance + conflict,
  data = panel_df,
  cluster = ~iso3
)

# Model 3: Country fixed effects
m3 <- feols(
  log_displacement ~ flood_events + drought_events + 
    log_gdp_pc + log_pop + urban_rate + governance + conflict | iso3,
  data = panel_df,
  cluster = ~iso3
)

# Model 4: Two-way fixed effects (main model)
m4 <- feols(
  log_displacement ~ flood_events + drought_events + 
    log_gdp_pc + log_pop + urban_rate + governance + conflict | iso3 + year,
  data = panel_df,
  cluster = ~iso3
)

# View results
etable(m1, m2, m3, m4)

# Coefficient plot of main model
library(ggplot2)

iplot(m4, 
      main = "Two-Way Fixed Effects: Climate Events & Displacement",
      xlab = "Coefficient estimate")

coefplot(m4,
         main = "Two-Way Fixed Effects: Climate Events & Displacement",
         xlab = "Coefficient Estimate")

# Save the coefplot
png("results_coefplot.png", width = 800, height = 600)
coefplot(m4,
         main = "Two-Way Fixed Effects: Climate Events & Displacement",
         xlab = "Coefficient Estimate")
dev.off()

# Also save your results table
library(modelsummary)
modelsummary(
  list("Baseline" = m1, "Controls" = m2, 
       "Country FE" = m3, "Two-Way FE" = m4),
  stars = TRUE,
  output = "results_table.html"
)

**********************************************
  library(ggplot2)
library(dplyr)

# ============================================
# 1. GLOBAL DISPLACEMENT OVER TIME
# ============================================

panel_df %>%
  group_by(year) %>%
  summarise(total = sum(displacement, na.rm = TRUE)) %>%
  ggplot(aes(x = year, y = total / 1e6)) +
  geom_line(color = "#e74c3c", size = 1.2) +
  geom_point(color = "#e74c3c", size = 2.5) +
  labs(
    title = "Global Climate-Induced Internal Displacement (2008–2024)",
    x = "Year", y = "People Displaced (Millions)"
  ) +
  theme_minimal(base_size = 13)

ggsave("plot1_displacement_over_time.png", width = 9, height = 5)

# ============================================
# 2. TOP 20 MOST DISPLACED COUNTRIES
# ============================================

panel_df %>%
  group_by(iso3) %>%
  summarise(total = sum(displacement, na.rm = TRUE)) %>%
  arrange(desc(total)) %>%
  slice(1:20) %>%
  mutate(country = countrycode(iso3, "iso3c", "country.name")) %>%
  ggplot(aes(x = reorder(country, total), y = total / 1e6)) +
  geom_col(fill = "#2980b9") +
  coord_flip() +
  labs(
    title = "Top 20 Countries by Climate Displacement (2008–2024)",
    x = "", y = "Total People Displaced (Millions)"
  ) +
  theme_minimal(base_size = 12)

ggsave("plot2_top20_countries.png", width = 9, height = 7)

# ============================================
# 3. FLOODS VS DISPLACEMENT SCATTER
# ============================================

panel_df %>%
  filter(flood_events > 0) %>%
  ggplot(aes(x = flood_events, y = log_displacement)) +
  geom_point(alpha = 0.4, color = "#2980b9") +
  geom_smooth(method = "lm", color = "#e74c3c", se = TRUE) +
  labs(
    title = "Flood Events vs Internal Displacement",
    x = "Number of Flood Events",
    y = "Log(Displacement)"
  ) +
  theme_minimal(base_size = 13)

ggsave("plot3_floods_scatter.png", width = 8, height = 6)

# ============================================
# 4. DROUGHTS VS DISPLACEMENT SCATTER
# ============================================

panel_df %>%
  filter(drought_events > 0) %>%
  ggplot(aes(x = drought_events, y = log_displacement)) +
  geom_point(alpha = 0.4, color = "#e67e22") +
  geom_smooth(method = "lm", color = "#e74c3c", se = TRUE) +
  labs(
    title = "Drought Events vs Internal Displacement",
    x = "Number of Drought Events",
    y = "Log(Displacement)"
  ) +
  theme_minimal(base_size = 13)

ggsave("plot4_droughts_scatter.png", width = 8, height = 6)

# ============================================
# 5. WORLD MAP
# ============================================

library(maps)

world <- map_data("world") %>%
  mutate(iso3 = countrycode(region, "country.name", "iso3c"))

map_data_df <- panel_df %>%
  group_by(iso3) %>%
  summarise(total = sum(displacement, na.rm = TRUE))

world_joined <- left_join(world, map_data_df, by = "iso3")

ggplot(world_joined, aes(x = long, y = lat, group = group, fill = total / 1e6)) +
  geom_polygon(color = "white", size = 0.1) +
  scale_fill_gradient(
    low = "#fff7bc", high = "#e74c3c",
    na.value = "grey90",
    name = "Displaced\n(Millions)"
  ) +
  labs(
    title = "Climate-Induced Internal Displacement by Country (2008–2024)",
    x = "", y = ""
  ) +
  theme_void(base_size = 13) +
  theme(legend.position = "right")

ggsave("plot5_world_map.png", width = 12, height = 7)

# ============================================
# 6. PREDICTED VS ACTUAL
# ============================================















