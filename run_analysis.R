##########################################################################################################

## Coursera Getting and Cleaning Data Course Project
## Wolfgang Brandl
## 2016-03-26

# run_nalysis.r File Description:

# This script will perform the following steps on the UCI HAR Dataset downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

##########################################################################################################
# Clean up workspace
rm(list=ls())
TidyNames <- function(Names) {
  Names = gsub("\\()","",Names)
  Names = gsub("-std$","StdDev",Names)
  Names = gsub("-mean","Mean",Names)
  Names = gsub("^(t)","Time",Names)
  Names = gsub("^(f)","Freq",Names)
  Names = gsub("([Gg]ravity)","Gravity",Names)
  Names = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",Names)
  Names = gsub("[Gg]yro","Gyro",Names)
  Names = gsub("AccMag","AccMagnitude",Names)
  Names = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",Names)
  Names = gsub("JerkMag","JerkMagnitude",Names)
  Names = gsub("GyroMag","GyroMagnitude",Names)
}

# 1. Merge the training and the test sets to create one data set.

#set working directory to the location where the UCI HAR Dataset was unzipped
wd <- file.path ("C:","Users","Wolfi","Getting-and-Cleaning-Data-Course-Project")
setwd (wd)
if (!file.exists("data")){
  dir.create("data")
}
wd <- file.path ("C:","Users","Wolfi","Getting-and-Cleaning-Data-Course-Project","data")
setwd (wd)

# Read in the data from files
features     = read.table('./features.txt',header=FALSE); #imports features.txt
activityType = read.table('./activity_labels.txt',header=FALSE); #imports activity_labels.txt
subjectTrain = read.table('./train/subject_train.txt',header=FALSE); #imports subject_train.txt
xTrain       = read.table('./train/x_train.txt',header=FALSE); #imports x_train.txt
yTrain       = read.table('./train/y_train.txt',header=FALSE); #imports y_train.txt

# Assigin column names to the data imported above
colnames(activityType)  = c('activityId','activityType');
colnames(subjectTrain)  = "subjectId";
colnames(xTrain)        = features[,2]; 
colnames(yTrain)        = "activityId";

# cCreate the final training set by merging yTrain, subjectTrain, and xTrain
trainingData = cbind(yTrain,subjectTrain,xTrain);

# Read in the test data
subjectTest = read.table('./test/subject_test.txt',header=FALSE); #imports subject_test.txt
xTest       = read.table('./test/x_test.txt',header=FALSE); #imports x_test.txt
yTest       = read.table('./test/y_test.txt',header=FALSE); #imports y_test.txt

# Assign column names to the test data imported above
colnames(subjectTest) = "subjectId";
colnames(xTest)       = features[,2]; 
colnames(yTest)       = "activityId";


# Create the final test set by merging the xTest, yTest and subjectTest data
testData = cbind(yTest,subjectTest,xTest);


# One data frame for traning and test
finalDF = rbind(trainingData,testData);

# Create a vector for the column names from the finalData, which will be used
# to select the desired mean() & stddev() columns
colNames  = colnames(finalDF); 

# 2. Extract only the measurements on the mean and standard deviation for each measurement. 

# Create a logicalVector that contains TRUE values for the ID, mean() & stddev() columns and FALSE for others
logicalVector = (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames));

# Subset finalData table based on the logicalVector to keep only desired columns
finalDF = finalDF[logicalVector==TRUE];

# 3. Use descriptive activity names to name the activities in the data set

# Merge the finalData set with the acitivityType table to include descriptive activity names
finalDF = merge(finalDF,activityType,by='activityId',all.x=TRUE);

# Updating the colNames vector to include the new column names after merge
colNames  = colnames(finalDF); 

# 4. Appropriately label the data set with descriptive activity names. 
colNames <- sapply (colNames,TidyNames)

# Reassigning the new descriptive column names to the finalData set
colnames(finalDF) = colNames;

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Create a new table, finalDataNoActivityType without the activityType column
finalDataNoActivityType  = finalDF[,names(finalDF) != 'activityType'];

# Summarizing the finalDataNoActivityType table to include just the mean of each variable for each activity and each subject
tidyData    = aggregate(finalDataNoActivityType[,names(finalDataNoActivityType) != c('activityId','subjectId')],by=list(activityId=finalDataNoActivityType$activityId,subjectId = finalDataNoActivityType$subjectId),mean);

# Merging the tidyData with activityType to include descriptive acitvity names
tidyData    = merge(tidyData,activityType,by='activityId',all.x=TRUE);

# Export the tidyData set 
write.table(tidyData, './tidyData.txt',row.names=TRUE,sep='\t')
