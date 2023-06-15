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
install.packages("ggrepel")

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(ggrepel)


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

# First, we will have to convert the data from wide to long format.
plot_bar <- results %>%
  pivot_longer(cols = starts_with(c("true_", "false_")), 
               names_to = "category",
               values_to = "count")

# Let's have a look at our data now
dim(results)
colnames(results)
head(results)

# Finally, we want to specify the order that our categories will appear in
plot_bar$category <- as.factor(plot_bar$category)
plot_bar$category <- factor(plot_bar$category, levels = c("false_pos", "false_neg", "true_pos", "true_neg"))


# 5.4: Create Bar Graph ========================================================

# Now our data is in the correct format, we can create a bar graph.

plot_bar <- ggplot(plot_bar, aes(x = method, y = count, fill = category)) +
  geom_bar(position = "fill", stat = "identity") +
  scale_fill_manual(values = c("true_pos" = "pink", 
                               "true_neg" = "purple",
                               "false_pos" = "aquamarine",
                               "false_neg" = "grey"),
                    labels = c("False negatives",
                               "False positives",
                               "True positives",
                               "True negatives")) +
  labs(x = "Method", y = "Percent", fill = "Key") +
  ggtitle("Comparison of 3 methods to identify retracted articles") +
  theme_bw()


# 5.5: Create Scatter Plot =====================================================

plot_scatter <- ggplot(results, aes(x=sensitivity, y=specificity)) + 
  geom_point() +
  geom_text_repel(aes(label = method)) +
  labs(x = "Sensitivity", y = "Specificity") +
  ggtitle("Sensitivity and specificity of 3 methods to identify retracted articles") +
  theme_bw()

# 5.6: Save Graphs =============================================================

# We can save our graphs as image files.

# Create a  `graphics folder`
dir.create("graphics")

# Save as a png file
ggsave("graphics/stacked_barplot.png", plot = plot_bar, width = 8, height = 6, dpi = 300)
ggsave("graphics/scatterplot.png", plot = plot_scatter, width = 8, height = 6, dpi = 300)
