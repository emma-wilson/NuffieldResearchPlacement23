# 4: Data Analysis #############################################################

# In this R script we will:
#  - Load the relevant R packages
#  - Read in validated data
#  - Analyse the data:
#  - Save the result


# 4.1: Load R Packages =========================================================

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)


# 4.2: Read In Validated Data ==================================================

# Now that we have validated the dataset, we can read that data into R.

# Read in validated data
data_val <- read.csv("data-validation/retractions-validated.csv")
  
# Let's have a look at the data
dim(data_val)
colnames(data_val)
head(data_val)


# 4.3: Analyse the Data ========================================================

# We want to work out how many retracted publications were identified by each 
# method. We can do this by comparing the is_retracted columns.

# Let's start by creating an empty dataframe for the results data
results <- data.frame(method = as.character(),
                      true_pos = as.numeric(),
                      true_neg = as.numeric(),
                      false_pos = as.numeric(),
                      false_neg = as.numeric())

# The method column will contain the method used to identify the retractions,
# e.g. openalex

# True positives are the studies that are retracted that are correctly 
# identified as retractions.

# True negatives are the studies that are not retracted that are correctly not
# identified as retractions.

# False positives are studies which are identified as retractions when they 
# really aren't.

# False negatives are studies which have not been identified as retractions when
# they really are.

# Next we want to get the data to fill the results and combine this with our
# results dataframe.

# Get results for open alex
results_openalex <- data.frame(method = "openalex",
                               true_pos = length(which(
                                 data_val$openalex == TRUE &
                                   data_val$is_retracted_validation == TRUE)),
                               true_neg = length(which(
                                 data_val$openalex == FALSE & 
                                   data_val$is_retracted_validation == FALSE)),
                               false_pos = length(which(
                                 data_val$openalex == TRUE & 
                                   data_val$is_retracted_validation == FALSE)),
                               false_neg = length(which(
                                 data_val$openalex == FALSE & 
                                   data_val$is_retracted_validation == TRUE)))

# Combine this with results dataframe
results <- rbind(results, results_openalex)


# 4.3.1: Exercise --------------------------------------------------------------

# Write code to do this for endnote and bibliographic








# Let's have a look at the data
view(results)


# 4.4: Calculate Sensitivity and Specificity ===================================

# Now we want to work out the sensitivity and specificity of each method.

# In this case, the sensitivity is the ability of each method to correctly
# identify retractions, and the specificity is the ability of each method to
# correctly identify when a study is not retracted.

# Sensitivity = Number of True Positives / (Number of True Positives + Number of False Negatives)
# Specificity = Number of True Negatives / (Number of True Negatives + Number of False Positives)

# Let's get the sensitivity and specificity for each method
results <- results %>%
  mutate(sensitivity = true_pos / (true_pos + false_neg),
         specificity = true_neg / (true_neg + false_pos))

# 4.5: Save Results Data =======================================================

# It's important that we don't lose our data so we have to save it.

# Create a folder called `data-analysed`
dir.create("data-analysed")

# Save our retraction data as a csv file in the `data-analysed` folder.
write_csv(results, "data-analysed/results.csv")
