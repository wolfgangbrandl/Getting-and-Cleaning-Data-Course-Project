# Getting and Cleaning Data - Course Project

This Assignment for the Getting and Cleaning Data Coursera course.
The R script `run_analysis.R` makes the following:

1. Download the dataset if it does not already exist in the working directory
2. Load the activity and feature info
3. Loads both the training and test datasets, keeping only those columns which
   reflect a mean or standard deviation
4. Loads the activity and subject data for each dataset, and merges those
    columns with the dataset
5. Merges the two datasets
6. Converts the `activity` and `subject` columns into factors
7. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

