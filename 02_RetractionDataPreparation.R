# 2: Retraction Data Preparation ###############################################

# In this R script we will:
#  - Load the relevant R packages
#  - Read in and format data from the following sources:
#      - Open Alex identified retractions
#      - EndNote identified retractions
#      - Bibliographic database identified retractions
#  - Combine retraction data into one dataset
#  - Save retraction data


# 2.1:  Load R Packages ========================================================

# Load the relevant packages (you need to load this in every new R session)
library(dplyr)
library(readr)


# 2.2: Read in SOLES Data ======================================================

# Let's read in our combined SOLES data so we can join it to our retraction
# data.

soles <- read_csv("data-processed/soles-combined.csv")

# We only want a few of the columns from soles, so let's select these.

soles <- soles %>%
  select(uid, soles_id, doi, title, author, journal, year)


# 2.3: Read and Format Open Alex Data ==========================================

# We previously collected some data on whether publications were retracted or
# not using the Open Alex database. We did this in advance as it takes some
# time to download all the data.

# Read in Open Alex Data
retract_openalex <- read_csv("data-raw/retractions-openalex.csv")

# Let's have a look at the data
dim(retract_openalex)
colnames(retract_openalex)
head(retract_openalex)

# Let's merge it with the SOLES data
retract_openalex <- merge(retract_openalex, soles, by = "doi")

# Now have another look at the data
dim(retract_openalex)
colnames(retract_openalex)
head(retract_openalex)


# 2.4: Read and Format EndNote Data ============================================

# We previously collected some data on whether publications were retracted or
# not using EndNote's integration with Retraction Watch. We did this in advance 
# as it requires access to EndNote.

# Read in EndNote Data
retract_endnote <- read_csv("data-raw/retractions-endnote.csv")

# Let's have a look at the data
dim(retract_endnote)
colnames(retract_endnote)
head(retract_endnote)

# Let's merge it with the SOLES data
# We can use the uid this time
retract_endnote <- merge(retract_endnote, soles, by = "uid")

# Now have another look at the data
dim(retract_endnote)
colnames(retract_endnote)
head(retract_endnote)


# 2.5: Read and Format Bibliographic Data ======================================

# All of the publications included in the SOLES databases are from various
# bibliographic databases.

# Many of these databases also contain information on whether publications are
# retracted or not.

# We searched these databases using the original SOLES searches, with an
# additional filter for retracted items.

# Read in Bibliographic Data
retract_pubmed <- read_csv("data-raw/retractions-pubmed.csv")
retract_scopus <- read_csv("data-raw/retractions-scopus.csv")
retract_wos    <- read_csv("data-raw/retractions-wos.csv")

# Now we can combine the data into one big dataset
retract_biblio <- rbind(retract_pubmed, retract_scopus, retract_wos)

# And remove the old datasets so we don't get confused
rm(retract_pubmed, retract_scopus, retract_wos)

# Let's have a look at the data
dim(retract_biblio)
colnames(retract_biblio)
head(retract_biblio)

# Let's merge it with the SOLES data
# We can use the uid this time
retract_biblio <- merge(retract_biblio, soles, by = "uid")

# Now have another look at the data
dim(retract_biblio)
colnames(retract_biblio)
head(retract_biblio)

# Notice there are fewer rows? That's because not everything picked up in the
# searches is in SOLES.


# 2.6: Combine Retraction Data Into One Dataset ================================

# Now we can combine all the retraction datasets into one.
retract <- rbind(retract_openalex, retract_endnote, retract_biblio)

# To avoid confusion, let's remove the individual datasets from our environment.
rm(retract_openalex, retract_endnote, retract_biblio)

# Let's have a look at our new dataset
dim(retract)
colnames(retract)
head(retract)


# 2.7: Save Retraction Data ====================================================

# It's important that we don't lose our data so we have to save it.

# Save our retraction data as a csv file in the `data-processed` folder.

write_csv(retract, "data-processed/retractions-combined.csv")
