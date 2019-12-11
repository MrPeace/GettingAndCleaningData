library(dplyr)
library(magrittr)

# Download and unzip file
filename <- "./data/DataDownload.zip"
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method="curl")
}

if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# Create DataFrames
features <- read.table("./UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Merge
All_x <- rbind(x_train, x_test)
All_y <- rbind(y_train, y_test)
All_Subject <- rbind(subject_train, subject_test)
All_Data <- cbind(All_Subject, All_y, All_x)

# Get mean's and std's
CleanData <- All_Data %>% 
    select(subject, code, contains("mean"), contains("std"))

# Get the names
All_Data$code <- activities[All_Data$code, 2]

# Add full names
names(All_Data)[2] = "activity"
names(All_Data)<-gsub("Acc", "Accelerometer", names(All_Data))
names(All_Data)<-gsub("Gyro", "Gyroscope", names(All_Data))
names(All_Data)<-gsub("BodyBody", "Body", names(All_Data))
names(All_Data)<-gsub("Mag", "Magnitude", names(All_Data))
names(All_Data)<-gsub("^t", "Time", names(All_Data))
names(All_Data)<-gsub("^f", "Frequency", names(All_Data))
names(All_Data)<-gsub("tBody", "TimeBody", names(All_Data))
names(All_Data)<-gsub("-mean()", "Mean", names(All_Data), ignore.case = TRUE)
names(All_Data)<-gsub("-std()", "STD", names(All_Data), ignore.case = TRUE)
names(All_Data)<-gsub("-freq()", "Frequency", names(All_Data), ignore.case = TRUE)
names(All_Data)<-gsub("angle", "Angle", names(All_Data))
names(All_Data)<-gsub("gravity", "Gravity", names(All_Data))

# Group and Summary
Final_Data <- All_Data %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))

# Save the data
write.table(Final_Data, ".data/Final_Data.txt", row.name=FALSE)