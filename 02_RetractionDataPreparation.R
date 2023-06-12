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

# 2.2: Read and Format Open Alex Data ==========================================

# We previously collected some data on whether publications were retracted or
# not using the Open Alex database. We did this in advance as it takes some
# time to download all the data.

# Read in Open Alex Data
retract_openalex <- read_csv("data-raw/retractions-openalex.csv")

# Let's have a look at the data
dim(retract_openalex)
colnames(retract_openalex)
head(retract_openalex)

# Let's format the data in a way that's consistent
retract_openalex <- retract_openalex %>%
  mutate(method = "openalex") %>%
  select(doi, is_retracted, date, method)


# 2.3: Read and Format EndNote Data ============================================

# We previously collected some data on whether publications were retracted or
# not using EndNote's integration with Retraction Watch. We did this in advance 
# as it requires access to EndNote.

# Read in EndNote Data
retract_endnote <- read_csv("data-raw/retractions-endnote.csv")

# Let's have a look at the data
dim(retract_endnote)
colnames(retract_endnote)
head(retract_endnote)

# Let's format the data in a way that's consistent
retract_endnote <- retract_endnote %>%
  mutate(method = "endnote") %>%
select(doi, is_retracted, date, method)


# 2.4: Read and Format Bibliographic Data ======================================

# All of the publications included in the SOLES databases are from various
# bibliograph databases.

# Many of these databases also contain information on whether publications are
# retracted or not.

# We searched these databases using the original SOLES searches, with an
# additional filter for retracted items.

# Read in Bibliographic Data
retract_pubmed <- read_csv("data-raw/retractions-pubmed.csv")
retract_embase <- read_csv("data-raw/retractions-embase.csv")
retract_scopus <- read_csv("data-raw/retractions-scopus.csv")
retract_wos    <- read_csv("data-raw/retractions-wos.csv")

# Next, we need to format a unique ID (uid) for each record so we can match 
# retracted items to our database. Formatting the uid is different for each
# bibliographic database.
retract_pubmed$uid <- paste0("pubmed-",pmid)
retract_embase$uid <- paste0("embase-",accession)
retract_scopus$uid <- paste0("scopus-",accession)
retract_wos$uid    <- paste0("wod-",accession)

# Now we can combine the data into one big dataset
retract_biblio <- rbind(retract_pubmed, retract_embase, 
                        retract_scopus, retract_wos)

# And remove the old datasets so we don't get confused
rm(retract_pubmed, retract_embase, retract_scopus, retract_wos)

# Let's have a look at the data
dim(retract_biblio)
colnames(retract_biblio)
head(retract_biblio)

# Let's format the data in a way that's consistent
retract_biblio <- retract_biblio %>%
  mutate(method = "bibliographic") %>%
select(uid, doi, is_retracted, date, method)


# 2.5: Combine Retraction Data Into One Dataset ================================

# Before we can combine the retractions identified from open alex, endnote, and
# bibliographic databases, we need to make sure all the columns are the same.

# The bibliographic data contains a uid column, but the others don't.
# The uid column helps us connect data back up to the SOLES dataset.

# Let's add a uid column.

# First, read in the processed SOLES data
soles <- read_csv("data-processed/soles-combined.csv") %>%
  select(uid, doi)

# Now we can use the doi column to get the uid
retract_openalex <- merge(retract_openalex, soles, by = "doi")


# 2.5.1: Exercise --------------------------------------------------------------

# Write code to do the same with the `retract_endnote` dataset.








# Now we can combine all the retraction datasets into one.
retract <- rbind(retract_openalex, retract_endnote, retract_biblio)

# To avoid confusion, let's remove the individual datasets from our environment.
rm(retract_openalex, retract_endnote, retract_biblio)

# Let's have a look at our new dataset
dim(retract)
colnames(retract)
head(retract)


# 2.6: Save Retraction Data ====================================================

# It's important that we don't lose our data so we have to save it.

# Save our retraction data as a csv file in the `data-processed` folder.

write_csv(soles, "data-processed/retractions_combined.csv")