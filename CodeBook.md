#
# Cleaning data code book
#
#

## First of all I should thank these two individuals who contributed code to github
## https://github.com/sudar/UCI-HAR-Dataset-Analysis/
## https://github.com/vgm1913/R-GettingAndCleaningData
## Their work helped me to understand the assignment and experiment with working code
##

## Description

run_analysis.R scripts downloads, unpacks, merges the training and test data sets provided for the 30 subjects in UCI HAR experiment. The script selects only the Mean and Standard Diviation of measurements taken for each subject and activity. It then labels the information (columns) with descriptive names. The result is transformed into a tidy table with each Activity measurement by Subject being stored in 1 row while every unique measurement of mean & SD stored as a unique column. 

## Requirements

    Internet Connection: Required for download of UCI HAR zip file.
    working directory with write permissions: Required for unpacking and installing data files.

## Attributes
    NO Attributes Used

## Detail Specification

run_analysis is a specific script designed to work with UCI HAR dataset HAR = Human Activity Recognition using smart phones Dataset (see http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) & performs the following:

    Merges the training and the test sets to create one data set
    Extracts only the measurements on the mean and standard deviation for each measurement
    Uses descriptive activity names + Appropriately labels the data set 
    Creates independent tidy data set with the average of each variable for each activity and each subject

## Assumptions & Meta-Data information

    A) all data is stored under ./data directory under the current working directory of the script
    B) activity_labels.txt contains the labels for measured Human Activities - use these labels in association with y_train.txt or y_test.txt files
    C) features.txt contains the labels for columns for the data measurements stored in the test or train sub-directories under X_train.txt & X_test.txt files
    D) run_analyis.R script outputs to the local working directory to a file named: run_analysis-Activity_Subject_Measurement_Means.txt
