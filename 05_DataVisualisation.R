# 5: Data Visualisation ########################################################

# In this R script we will:
#  - Load the relevant R packages
#  - Read in analysed data
#  - Format data for graph
#  - Create graphs to visualise the data
#  - Save the graphs


# 5.1: Install R Packages ======================================================

# Install the relevant packages (you only need to do this once)
install.packages("ggplot2")

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)
library(ggplot2)


# 5.2: Read In Analysed Data =========================+=========================

# Read in processed retractions data
results <- read_csv("data-analysed/results.csv")

# Have another look at the data
dim(results)
colnames(results)
head(results)


# 5.3: Format Data For Graph ===================================================

# We want to create a bar chart to visualise our data. There will be a bar for
# each method, and each bar will show to number of true positives, false
# positives, and false negatives.

# First, we want to remove the false negative column as we don't want this in
# our graph.
results <- results %>%
  select(-false_neg)

# Next, we will have to convert the data from wide to long format.
results <- results %>%
  pivot_longer(cols = starts_with(c("true_", "false_")), 
               names_to = "category",
               values_to = "count")

# Let's have a look at our data now
dim(results)
colnames(results)
head(results)


# 5.4: Create Graph ============================================================

# Now our data is in the correct format, we can create the graph.

plot_bar <- ggplot(results, aes(x = method, y = count, fill = category)) +
  geom_bar(position = "fill", stat = "identity") +
  scale_fill_manual(values = c("true_pos" = "green", 
                               "true_neg" = "blue",
                               "false_pos" = "red",
                               "false_neg" = "orange")) +
  labs(x = "Method", y = "Count", fill = "Category") +
  ggtitle("Stacked Barplot of Results")


# 3.5: Save Graphs =============================================================

# We can save our graphs as image files.

# Create a  `graphics folder`
dir.create("graphics")

# Save as a png file
ggsave("graphics/stacked_barplot.png", width = 8, height = 6, dpi = 300)