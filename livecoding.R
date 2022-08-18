### A Short Introduction into Data Science with R
### August 18, 2022
### Presenter:  Robert Ladwig
### based on material by:  Rachel Pilla, Andrew Cannizzarro & Nicole Berry
### Bird banding data provided by Dr. Dave Russell at Miami University in 
### collaboration with Hueston Woods State Park

######################################
### Introduction to R and packages ###
######################################

### Presentation:
# - what is data science?
# - what is R?
# - layout/panes of RStudio
# - packages and installing
# - help files
# - using an R script (ALWAYS use script; how to run code; adding comments;
#   case sensitive; spaces, parentheses, quotations; carrot in console vs. +)
# - functions, arguments, and objects
# - types of data (numeric, integer, character, logical, complex)
# - data structures (vector, matrix, data frame)

### LIVE CODING (remainder of Day 1)


###################
### Basics in R ###
###################

# INSTALLING PACKAGE

install.packages("tidyverse")
# or install.packages("dplyr")
# and install.packages("ggplot2") if internet is too slow for "tidyverse"


# LOADING PACKAGE

library(tidyverse)

######################################
# R is a calculator
5 + 4
8 / 2
(2 + 7) * 3

######################################
# WHAT IS AN OBJECT?
# Saving objects in R, and viewing object data
# (Environment Pane; how to name "best" - must begin with letter, caps or lowercase accepted;
# name objects clearly and consistently)
a <- 5 + 4
b <- 8 / 2
c <- a - b

a
b
c

######################################
# Saving a script (file naming...) - do this now
# Scripts can be shared, edited, resaved, copy/pasted, etc. (much like a text editor)


# Style tips for writing code:
# 1) R is case sensitive ("A" does not equal "a")
# 2) Best practice is to put spaces between object, values, commas, etc. (though R does not require this)
# 3) Missing parentheses, commas, or quotation marks cause a vast majority of errors
# 4) Your collaborators and future self will appreciate detailed comments
# 5) Make sure the console has a blue ">" before running (if it has a "+" then it DID NOT FINISH the previous code for some reason)

######################################
# Errors and warning messages
# Errors BREAK the code, warnings run it (often not an issue, but keep an eye out that R is doing what you want)
A
c <- b - 3) * 2
cbind(c(1, 2, 3), c(1, 2, 3, 4))


# Basic functions and help files

?mean
?c

vector1 <- c(1, 2, 3, 4, 5)
vector1

mean(vector1)
sqrt(vector1)

# Types of data in R:
# numeric/integer, character/strings, logical, factor (others are less common)

# Types of data structures in R:
# 1) vector - 1D, holds only 1 type of data
# 2) matrix - 2D, holds only 1 type of data
# 3) data frame - 2D, each column can be different type of data
# data frame is very common and useful; other types are generally less common (e.g., lists)

df1 <- data.frame("Column1" = c("A", "B", "C", "D", "E"),
                  "Column2" = vector1,
                  "Column3" = c("I", "am", "doing", "data", "science"))
df1

head(df1, n = 3)
tail(df1, n = 2)
str(df1)
summary(df1)



##############################
### Working with data in R ###
##############################
# PRACTICE loading csv file into R
# (a new data file -- bird banding data)

# 1) load in the data file and peek at the columns/structure

file <- file.choose()
birds <- read.csv(file)

birds

head(birds)
str(birds)

# 2) calculate the average, maximum and minimum annual count column

mean(birds$AnnualCount)
max(birds$AnnualCount)
min(birds$AnnualCount)

# 3) find the earliest and latest year of data

min(birds$Year)
max(birds$Year)

# OR

range(birds$Year)

# 4) INDEXING:
#    a) find the species and year that had the highest recorded count
#    b) find how many unique species are in the data set (HINT:  function "unique")
#    c) find the average count for all Long distance migrants in the year 2010

birds$CommonName[which.max(birds$AnnualCount)]
birds$Year[which.max(birds$AnnualCount)]

length(unique(birds$CommonName))

mean(birds$AnnualCount[birds$Year == 2010 & birds$MigrationType == "Long distance migrant"])

#########################
### Manipulating data ###
#########################

# dplyr: four main functions and pipe tool
# data frame name is ALWAYS the first argument for these if using alone

?select
?filter
?mutate
?summarize

## choose specific column(s) by name

BirdNamesCounts <- select(birds, CommonName, AnnualCount)
BirdNamesCounts


## choose row(s) by condition

Year2016 <- filter(birds, Year == 2016)
Year2016


# create new column(s)

AboveBelow <- mutate(birds, AboveBelowAvg = ifelse(AnnualCount > 8, TRUE, FALSE))
AboveBelow


# summarize (must become fewer rows than original)
MeanCount <- summarize(birds, MeanCount = mean(AnnualCount))
MeanCount



# pipe tool for multiple steps at once
# do NOT need to name data frame if using this, since it will automatically start with the 
# data frame remaining from the previous line of code

PopularBirds <- birds %>%
  filter(AnnualCount >= 8) %>%
  select(Year, CommonName, AnnualCount)
PopularBirds
unique(PopularBirds$CommonName)

## grouping and summarizing

TotalByMigration <- birds %>%
  group_by(Year, MigrationType) %>%
  summarize(TotalCount = sum(AnnualCount))
TotalByMigration


# PRACTICE
# using the dplyr tools, create a new object
# that gives the average number of Northern Cardinals in years since 2010 (inclusive)

RecentCardinals <- birds %>%
  filter(Year >= 2010,
         CommonName == "Northern Cardinal") %>%
  summarize(AvgCardinals = mean(AnnualCount))
RecentCardinals


# reformatting from long to wide to long using "spread"
# after summarizing (above) and then renaming
# (opposite of "spread" is "gather")

birdsWide <- TotalByMigration %>%
  select(Year, MigrationType, TotalCount) %>%
  spread(key = MigrationType, value = TotalCount) %>%
  rename(LongDistance = 'Long distance migrant',
         ShortDistance = 'Short distance migrant')
birdsWide


###########################
### Basic Plotting in R ###
###########################

## boxplot

boxplot(TotalCount ~ MigrationType,data = TotalByMigration)

boxplot(TotalCount ~ MigrationType,data = TotalByMigration,
        xlab = "Migration Type",
        ylab = "Annual Count")

## PRACTICE:
## make a scatterplot of the total long-distance birds per year with a trend line

plot(LongDistance ~ Year, data = birdsWide,
     xlab = "Annual Count",
     main = "Annual Counts of Long Distance Bird Migrants over Time",
     pch = 19,
     type = "o")
abline(lm(LongDistance ~ Year, data = birdsWide),
       lty = 2)

# using ggplot2-package, we can also make even more beautiful plots
ggplot(TotalByMigration, aes(Year, TotalCount, col = MigrationType)) +
  geom_point() + 
  geom_line() +
  geom_smooth(method=lm) +
  theme_minimal()

############################
### Statistical analyses ###
############################


## basic statistics in R

# correlation of bird migration types

cor(x = birdsWide$LongDistance, y = birdsWide$Resident)


# 2-sided t-test to compare two different sets of data/columns
# test if the means of two populations are significantly different to each other

t.test(x = birdsWide$LongDistance, y = birdsWide$Resident)

# ANOVA (1-way, analysis of variance)
# does migration type influence the annual count of birds?
# NOTE: data needs to be summarized in LONG format

bird.anova <- aov(TotalCount ~ MigrationType, data = TotalByMigration)
summary(bird.anova)

TukeyHSD(bird.anova)

#plot confidence intervals
plot(TukeyHSD(bird.anova, conf.level=.95), las = 2)

## LINEAR REGRESSION

# are the number of long-distance birds changing over time?

plot(LongDistance ~ Year, data = birdsWide,
     xlab = "Annual Count",
     main = "Annual Counts of Long Distance Bird Migrants over Time",
     pch = 19,
     type = "o")
abline(lm(LongDistance ~ Year, data = birdsWide),
       lty = 2)

bird.mod <- lm(LongDistance ~ Year, data = birdsWide)
summary(bird.mod)

