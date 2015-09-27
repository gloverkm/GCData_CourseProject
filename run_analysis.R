#make new folder for project and downloads
dir.create("KGProject")
list.files()
setwd("KGProject")

#download and unzip files
fileUrl1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl1, destfile = "GCD_project.zip", method = "curl")
unzip("GCD_project.zip")
#check if download worked
list.files()

#get into data set to see what is there
setwd("UCI HAR Dataset/")
list.files()
#read the README.txt just in case
#opened in TextWrangler
#move all data files to same directory, read in files test sets first, then train sets
subject_test2 <- read.table("subject_test.txt")
#add header and check input
colnames(subject_test2) = "Subject Number"
head(subject_test2)
nrow("subject_test2")
str("subject_test2")

features1 <- read.table("features.txt")
dim(features1)
head(features1)
#use this file to add headers and check input
ColNames_test <- make.names(features1[,-1], unique = FALSE)
head(ColNames_test)
str(ColNames_test)

X_test2 <- read.table("X_test.txt")
#add headers from above and check input
colnames(X_test2) = ColNames_test
names(X_test2)
head(X_test2)
nrow(X_test2)

y_test2 <- read.table("y_test.txt")
colnames(y_test2) = "Activity"
#go ahead and change integer values to names, using advice from Discusion board via Fran
y_test2$Activity <- as.factor(as.integer(y_test2$Activity))
levels(y_test2$Activity) <- c("walking", "walking_upstairs", "walking_downstairs", 
                                   "sitting", "standing", "laying") 

#test outputs of above with different calls
levels(y_test2)
head(y_test2)
dim(X_test2)
names(X_test2)
head(X_test2)
str(X_test2)
str(subject_test2)
names(subject_test2)
dim(subject_test2)

#read the read.me file again to understand column names and inputs
#I think I understand the data now. This data contains replicate experiments from the 
#same individual under the same activity, with a total of 10299 instances. This is further
#clarified in the updated, though unaccessible new dataset from the original weblink.
#begin data manipulation preparing for merging of test and train

#start dplyr, following swirl tutorial/class notes
library(dplyr)
test_df <- data.frame(subject_test2, y_test2, X_test2)
#put into tbldf
x_testDF <- tbl_df(test_df)
x_testDF

#repeat process for training set
setwd("~/Desktop/Getting Cleaning Data/KGProject/UCI HAR Dataset/train")
list.files()
subject_train2 <- read.table("subject_train.txt")
colnames(subject_train2) = "Subject Number"
head(subject_train2)
dim(subject_train2)
X_train2 <- read.table("X_train.txt")
dim(X_train2)
features2 <- read.table("features.txt")
dim(features2)
head(features2)

ColNames_X <- make.names(features2[,-1], unique = FALSE)
head(ColNames_X)
str(ColNames_X)
colnames(X_train2) = ColNames_X
names(X_train2)
head(X_train2)

y_train2 <- read.table("y_train.txt")
colnames(y_train2) = "Activity"
#go ahead and change integer values to names, using advice from Discusion board via Fran
y_train2$Activity <- as.factor(as.integer(y_train2$Activity))
levels(y_train2$Activity) <- c("walking", "walking_upstairs", "walking_downstairs", 
                              "sitting", "standing", "laying")

head(y_train2)
dim(y_train2)
library(dplyr)
train_df <- data.frame(subject_train2, y_train2, X_train2)
x_trainDF <- tbl_df(train_df)
x_trainDF

#before merging, mutate dfs so that downstream user can differentiate 
#between original datasets. Call new column "Dataset" with values "train" 
#or "test"
new_x_testDF <- mutate(x_testDF, "Dataset" = "test")
head(new_x_testDF$Dataset)
new_x_trainDF <- mutate(x_trainDF, "Dataset" = "train")
head(new_x_trainDF$Dataset)

dim(new_x_testDF)
dim(new_x_trainDF)

#ready to merge
mergedData = rbind(new_x_testDF, new_x_trainDF)
mergedData
tail(mergedData)
dim(mergedData)
#merge test, compare to original y txt files
smallmergetest <- select(mergedData, Subject.Number, Activity, Dataset)
head(smallmergetest)
tail(smallmergetest)
#looks good, ready to select specific columns with mean and sd
#time to select for just columns containing mean
almost_clean <- mergedData[, grep("Subject|Activity|Dataset|mean|std", names(mergedData))]
#time to average the experimental repeats, try with summarize
#try from discussion boards
clean_data <- almost_clean %>%
        group_by(Subject.Number,Activity) %>% summarise_each(funs(mean))
write.table(clean_data, "tidy_data.txt", sep = "|", row.name = FALSE)
#to read back into R use:
check_it_out <- read.table("tidy_data.txt", header = TRUE, sep = "|")
# double check the looks of the table
head(check_it_out)
dim(check_it_out)

                                   