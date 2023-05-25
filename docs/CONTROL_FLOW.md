# "parcel()" Control Flow Structure

> This is the `parcel()` commands control flow structure. The layout of the path that any file or folder passed in will take. I originally wrote this so I wouldn't personally get lost in my own code as I was writing it and figured it might help someone else as well. Allthough roughly written, the followwing chart does represent the actual parcel function exactly, so it is a reliable road map of the source. 


- Call to `parcel(test1.txt MyFolder)` 

## function parcel() {
 
- `read -p` Warn the user. Continue?
    - If ***yes*** continue
    - If ***no*** then `exit 0`


- Initialize variables: `THIS_DIRECTORY iteration_count targets total_targets current_directory parcel_directory random_suffix parcel_id parcel_name OUTPUT_DIRECTORY PARCEL THIS_DIRECTORY extension non_extension PARCEL_DATA_FILE PARCEL_LOG_START_DELIMETER PARCEL_LOG_ENDING_DELIMETER`

- Create `random_suffix` `parcel_name` `parcel_id`

- `mkdir $parcel_directory` create ***parcel/***
- `make-encryption-key` create ***encryption.key***
- `touch $PARCEL_DATA_FILE` create ***parcel.data***
- `mkdir $OUTPUT_DIRECTORY` create ***Parcels/***

- `parcel-log $PARCEL_LOG_START_DELIMETER` begin parcel.log
- `write-parcel-data $PARCEL_LOG_START_DELIMETER` begin parcel.data

### loop `for $target in ${targets}; do` {

Get the file extension or folder name or "non-extension" which contains `/` and/or has no `.`

  - `extension=".${target##*.}"` for Files.
  - `non_extension="${target##*.}/"` for directories

- ### condition `if [[ $iteration_count -ne $total_targets ]]; then`
    - Increment iteration count: `iteration_count=$((iteration_count + 1))`
  
  - ### condition if `-f` file:
    - `TARGET_DATA_STRING="$target : $extension : $parcel_id : $parcel_name"`
    - `encrypt-file test1.txt`
    - `mv test1.enc` --> ***parcel/***
    - `rm test1.txt` remove original file

  - ### condition if `-d` folder:
    - `TARGET_DATA_STRING="$target : $non_extension : $parcel_id : $parcel_name"` 
    - `zip MyFolder/` --> ***MyFolder.zip***
    - `mv MyFolder.zip` --> ***parcel/*** 
    - `rm -r MyFolder/` remove original folder
  - ### condition if invalid:
    - `TARGET_DATA_STRING="$target : [unknown] : $parcel_id : $parcel_name"`

    `write-parcel-data $TARGET_DATA_STRING` ---> ***parcel.data***
    `parcel-log $TARGET_DATA_STRING` ---> ***parcel.log***
    `continue`
### } 

Write ending delimeters to logs and data file.
- `parcel-log "$PARCEL_LOG_ENDING_DELIMETER"`
- `parcel-log ""`
- `write-parcel-data "$PARCEL_LOG_ENDING_DELIMETER"`

- `mv encryption.key` --> ***parcel/***
- `mv $PARCEL_DATA_FILE` --> ***parcel/***

- `zip parcel/` --> `parcel.zip`

- `mv parcel.zip` --> `parcel.parcel`

- `mv parcel.parcel` --> `4SYDP0E2TK.parcel`

- `mv 4SYDP0E2TK.parcel` --> `Parcels/`

`PARCEL="$(pwd)/$OUTPUT_DIRECTORY${parcel_name}"`

## }
