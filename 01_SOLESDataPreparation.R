# 1: SOLES Data Preparation ####################################################

# In this R script we will:
#  - Load the relevant R packages
#  - Read in data from the SOLES database
#  - Explore the SOLES dataset
#  - Combine and format the SOLES data
#  - Deal with missing data
#  - Save SOLES data


# 1.1: Install R Packages ======================================================

# Some of the R functions we will be using aren't part of the base R.
# We need to install and load these in separately.

# Note: You only need to install packages once. However, you will need to load 
# your R packages each time to open a new R session.

# Install the relevant packages (you only need to do this once)
install.packages("dplyr")
install.packages("readr")

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)


# 1.2: Read in SOLES Data ======================================================

# Our data are stored in the `data-raw` folder in our R project.
# We need to read in our data so that we can use it in R.

# Read in data from SOLES csv files
soles_ad     <- read_csv("data-raw/soles-ad.csv")
soles_ndc    <- read_csv("data-raw/soles-ndc.csv")
soles_stroke <- read_csv("data-raw/soles-stroke.csv")


# 1.3: Explore SOLES Data ======================================================

# We can write code to look at the number of columns and rows in each dataset.
dim(soles_ad)

# The first number in the output is the number of rows and the second number is 
# the number of columns.

# 1.3.1: Exercise --------------------------------------------------------------

# Write code to look at the number of columns and rows in the other datasets.








# Each SOLES dataset contains the same column names.
# Let's look at the column names in the Alzheimer's SOLES dataset.
colnames(soles_ad)

# Let's look at the data in the first few rows of the NDC SOLES dataset.
head(soles_ndc)

# ... And the last few rows of the NDC SOLES dataset.
tail(soles_ndc)


# Let's look at what type of data is in the title column of the Stroke SOLES 
# dataset.
class(soles_stroke$title)

# What about the date column of the Stroke SOLES dataset.
class(soles_stroke$date)
head(soles_stroke$date)

# Currently, the date is a character.
# We can fix the data column in each SOLES dataset so that it displays the date
# in the format YYYY-MM-DD, for example 2023-06-12
soles_stroke$date <- as.Date(soles_stroke$date, "%d%m%y")
# Check it worked
class(soles_stroke$date)
head(soles_stroke$date)

# 1.3.2: Exercise --------------------------------------------------------------

# Write code to fix the date column in the other datasets.








# Let's have a look at the oldest and most recent dates in AD SOLES
min(soles_ad$date) # Shows us the oldest date
max(soles_ad$date) # Shows us the most recent date


# 1.4: Combine and Format SOLES Data ===========================================

# We currently have 5 datasets with data from different SOLES projects.
# We want to combine the data into one big dataset.

# Before we do that, we want to keep a record of which datset each row came from.

# Add a soles_id column
soles_ad$soles_id         <- "ad"
soles_ndc$soles_id        <- "ndc"
soles_stroke$soles_id     <- "stroke"

# Now we can combine SOLES data into one big dataset.
soles <- rbind(soles_ad, soles_ndc, soles_stroke)

# To avoid confusion, let's remove the individual datasets from our environment.
rm(soles_ad, soles_ndc, soles_stroke)

# Let's have a look at our new dataset
dim(soles)
colnames(soles)
head(soles)


# 1.5: Check for uids which appear across multiple SOLES projects ==============

# Some uids may appear in more than one SOLES dataset.
# This means the sample record appears in e.g. AD-SOLES and Stroke-SOLES.
# We want to fix this so that each record only appear once in the combined
# dataset, and the soles_id correctly reflects all the SOLES projects a record
# is in.

# Find duplicates and correct the soles_id column
dups <- soles %>%
  filter(uid %in% soles[duplicated(soles$uid),]$uid) %>%
  group_by(uid) %>%
  mutate(soles_id_fix = paste0(soles_id, collapse = "; ")) %>%
  select(-soles_id) %>%
  rename(soles_id = soles_id_fix) %>%
  distinct(uid, .keep_all = T)

# Remove extra copies of duplicates from soles
soles <- rbind(filter(soles,!uid%in%dups$uid), dups)

# Have a look at our data now
dim(soles)
colnames(soles)
tail(soles$soles_id)
  

# 1.6: Deal with Missing Data ==================================================

# It's common for large datasets (and sometimes even small ones) to be missing
# some data.

# In R, missing data in signified by NA, which stands for Not Available.
# Sometimes, datasets may have blank cells where data is missing.
# In order for R to recognise it as missing data, we have to change blank cells 
# to NA.

# Change all blank cells to NA
soles[soles==""]<-NA

# Let's look at how much missing data we have.
sum(is.na(soles$title)) # Missing titles
sum(is.na(soles$doi)) # Missing digital object identifier (DOI)


# 1.7: Save SOLES Data =========================================================

# It's important that we don't lose our data so we have to save it.

# Create a folder for our processed data
dir.create("data-processed")

# Save our SOLES data as a csv file in the `data-processed` folder.

write_csv(soles, "data-processed/soles-combined.csv")
