#Load necessary packages
library(plyr)
library(data.table)
library(tidyr)

# Before Loading data Download and unzip dataset into working directory
# Data set file can be found in following web url
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Set working Direstory
#  setwd("D:\\DataScience")


#Load data files into variables
dataTest_X <- read.table("./UCI HAR Dataset/test/X_test.txt")
dataTrain_X <- read.table("./UCI HAR Dataset/train/X_train.txt")

#Load activity files into variables
dataTest_Y <- read.table("./UCI HAR Dataset/test/Y_test.txt")
dataTrain_Y <- read.table("./UCI HAR Dataset/train/Y_train.txt")

#Load subject files into variabls
data_test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
data_train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#1. Merging the training and the test sets to create one data set for both variable X, Y and subject each.

data_all_X <- rbind(dataTrain_X, dataTest_X)
data_all_Y <- rbind(data_train_Y, data_test_Y)
data_all_subject <- rbind(data_train_subject, data_test_subject)

#2. Extract only the measurements on the mean and standard deviation for each measurement.
#Load features.txt file and Get list of mean and std columns
data_features <- read.table("./UCI HAR Dataset/features.txt")
mean_std <- grep("-(mean|std)\\(\\)", data_features[, 2])

#Extract subset the mean and std columns
data_all_X <- data_all_X[, mean_std]

#Set column names
names(data_all_X) <- data_features[mean_std, 2]

#3. Use descriptive activity names to name the activities in the data set
#Load activity_labels.txt file and update correct activity name
data_activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
data_all_Y[, 1] <- data_activities[data_all_Y[, 1], 2]
names(data_all_Y) <- "activity"


#4. Label the data set with descriptive variable names based on appropriate data
# correct column name
names(data_all_subject) <- "subject"

# bind all the data in a single data set and update label of the data
all_data <- cbind(data_all_X, data_all_Y, data_all_subject)
names(all_data)<-gsub("std()", "SD", names(all_data))
names(all_data)<-gsub("mean()", "MEAN", names(all_data))
names(all_data)<-gsub("^t", "time", names(all_data))
names(all_data)<-gsub("^f", "frequency", names(all_data))
names(all_data)<-gsub("Acc", "Accelerometer", names(all_data))
names(all_data)<-gsub("Gyro", "Gyroscope", names(all_data))
names(all_data)<-gsub("Mag", "Magnitude", names(all_data))
names(all_data)<-gsub("BodyBody", "Body", names(all_data))


#5. Create a second, independent tidy data set with the average of each variable for each activity and each subject
avg <- ddply(all_data, .(subject, activity), function(x) colMeans(x[, 1:66]))

#Create tidy data set
write.table(avg, "tidydata.txt", row.name=FALSE)