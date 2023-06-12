# 3: Data Validation ###########################################################

# In this R script we will:
#  - Load the relevant R packages
#  - Read in processed retraction data
#  - Convert the data from long to wide format
#  - Prepare the data for validation and save


# 3.1: Install R Packages ======================================================

# Install the relevant packages (you only need to do this once)
install.packages("tidyr")

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)
library(tidyr)


# 3.2: Read In Processed Data ==================================================

# Read in processed retractions data
retract <- read_csv("data-processed/retractions-combined.csv")

# Have another look at the data
dim(retract)
colnames(retract)
head(retract)


# 3.3: Convert From Long to Wide ===============================================

# Our data are in a format called tidy data or long format data.
# We want to change it so that it's in wide format.

# Instead of having one column called method and one column called is_retracted,
# we want an is_retracted column for each method, e.g. is_retracted_openalex

# Reformat the data
retract <- retract %>%
  select(uid, method, is_retracted) %>%
  pivot_wider(
    names_from = method,
    names_glue = "{is_retracted}_{method}",
    values_from = is_retracted
  )


# 3.4: Prepare for Validation ==================================================

# Next we will want to validate our data. This means check if each identified
# retracted publication is actually retracted.

# To do this, let's create some extra columns to store our data validation info.
# We'll leave the rows blank for now.

retract <- retract %>%
  mutate(is_retracted_validation = "",
         validator_name = "")


# 3.5: Save Data For Validation ================================================

# It's important that we don't lose our data so we have to save it.

# Save our retraction data as a csv file in the `data-validation` folder.

write_csv(soles, "data-validation/retractions_for_validation.csv")

# We will download this file into Microsoft Teams to validate together.
# Once we have finished, we can upload the completed file.