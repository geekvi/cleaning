##
##  1. Merges the training and the test sets to create one data set
##  2. Extracts only the measurements on the mean and standard deviation for each measurement
##  3. Uses descriptive activity names to name the activities in the data set + Appropriately labels
##     the data set with descriptive variable names
##  4. From the data set in previous step, creates a second, independent tidy data set
##     with the average of each variable for each activity and each subject
##
## 

## INITIALIZE packages & declare dependencies
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

## run_analysis.R  Parameters
##  
##
DIR_data               <- "data"
ZIP_FILE_data          <- "UCI_HAR_dataset.zip"
URL_data               <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
FILE_activities        <- paste (DIR_data, "/activity_labels.txt", sep="")
FILE_features          <- paste (DIR_data, "/features.txt", sep="")
FILE_subject_train     <- paste(DIR_data, "/subject_train.txt", sep="")
FILE_subject_test      <- paste(DIR_data, "/subject_test.txt", sep="")
FILE_activity_train    <- paste(DIR_data, "/y_train.txt", sep="")
FILE_activity_test     <- paste(DIR_data, "/y_test.txt", sep="")
FILE_measurement_train <- paste(DIR_data, "/X_train.txt", sep="")
FILE_measurement_test  <- paste(DIR_data, "/X_test.txt", sep="")
FILE_output            <- "./run_analysis_output.txt"


load_and_label <- function (file1, new_colnames, file2 = "") {
  if (file2 == "") {
    DT <- data.table(read.table(file1))
  }
  else {
    DT <- rbindlist(
      list(data.table(read.table(file1)),
           data.table(read.table(file2))
      )
    )
  }
  setnames(DT, old=colnames(DT), new=new_colnames)
  DT
}

add_id_column <- function (data_table) {
  data_table[, id_seq := seq (from=1, to=nrow(data_table), by=1)]
  setkey(data_table, id_seq)
  data_table
}

transform_column_names <- function (char_vector) {
  x <- gsub (",", "-", char_vector)
  x <- gsub ("^t", "Time-", x) 
  x <- gsub ("^f", "Freq-", x) 
  x <- gsub ("mean\\(\\)", "Mean", x) 
  x <- gsub ("std\\(\\)", "SD", x) 
  x
}

## ------------------ Begin Script -----------------------
## Download and set up information
if (!file.exists(DIR_data)) {
  print(paste("Could not file ", DIR_data, " directory - creating the directory..."))
  dir.create(DIR_data)
}

if (!file.exists(ZIP_FILE_data)) {
  print("UCI HAR dataset zip not found, downloading ...")
  download.file(URL_data, destfile = ZIP_FILE_data)
}

if (!file.exists(FILE_features)) {
  print("unzipping the content of UCI HAR dataset zip file, wait...")
  unzip(ZIP_FILE_data, files = NULL, list = FALSE, overwrite = TRUE,
        junkpaths = TRUE, exdir = DIR_data, unzip = "internal",
        setTimes = FALSE)
}

## read Meta data information into R
print ("Initializing and loading Meta data...")
if (!file.exists(FILE_activities))
  stop (paste("run_analysis.R ERROR: could not find:", FILE_activities))

DT_act_labels <- load_and_label(FILE_activities, c("act_id", "Activity"))
setkey(DT_act_labels, act_id)

if (!file.exists(FILE_features))
  stop (paste("run_analysis.R ERROR: could not find:", FILE_features))

DT_feat_labels <- load_and_label(FILE_features, c("feat_id", "feat_label"))
setkey(DT_feat_labels, feat_id)

##
## Step 1 - Merge training and test sets into one data set
##
print ("Step 1 - Merging into one data set, wait...")
DT_HAR_data <- add_id_column (load_and_label (FILE_subject_train, c("Subject"), FILE_subject_test))

DT_act_data <- merge (
  add_id_column (load_and_label (FILE_activity_train, c("act_id"), FILE_activity_test)),
  DT_act_labels,
  by = "act_id",
  all = TRUE)
setkey(DT_act_data, id_seq)

## merge subject & activity information 
DT_HAR_data <- merge (DT_HAR_data, DT_act_data,all=TRUE)
setkey(DT_HAR_data, id_seq)

DT_HAR_feat <- add_id_column (
  load_and_label (FILE_measurement_train
                  , transform_column_names(
                    as.vector(DT_feat_labels[[2]])
                  )
                  , FILE_measurement_test)
)

setkey (DT_HAR_feat, id_seq)

##
## Step 2 - Extracting measurements on the mean and stadard deviation
##
print ("Step 2 Extracting measurements")
DT_feat_col_to_remove <- DT_feat_labels[ !(
  (like(feat_label,"mean()") & !(like(feat_label, "meanFreq()")))
  | (like (feat_label, "std()")))
  ]
feat_col_to_remove <- transform_column_names(as.vector(DT_feat_col_to_remove$feat_label))

for (col in feat_col_to_remove) {
  DT_HAR_feat <- DT_HAR_feat[, c(col) := NULL]
}
rm(col)
##
## Step 3 adding descriptive activity names
##
print ("Step 3 adding descriptive activity names")
DT_HAR_data <- merge (DT_HAR_data, 
                      DT_HAR_feat,
                      all=TRUE)
DT_HAR_data[, act_id := NULL] 
DT_HAR_data[, id_seq := NULL] 

## Clean
#rm(DT_HAR_feat)
#rm(DT_act_labels)
#rm(DT_act_data)
#rm(DT_feat_col_to_remove)
#rm(DT_feat_labels)
#rm(feat_col_to_remove)
##
## Step 4 - From the data set in previous step, creates a tidy dataset
##
print ("Step 4 - Creating a tidy data set")
DT_HAR_melt <- melt(DT_HAR_data, id=c("Activity", "Subject"))
DT_HAR_tidy <- dcast(DT_HAR_melt, Activity + Subject ~ variable, mean)

write.csv(DT_HAR_tidy, FILE_output, row.names = FALSE)
## ------------------ End Script -----------------------