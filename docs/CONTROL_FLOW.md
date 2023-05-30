# "parcel()" Control Flow Structure

> This is the `parcel()` commands control flow structure. The layout of the path that any file or folder passed in will take. I originally wrote this so I wouldn't personally get lost in my own code as I was writing it and figured it might help someone else as well. Allthough roughly written, the followwing chart does represent the actual parcel function exactly, so it is a reliable road map of the source. 

## parcel() {

  - Ask user if parcel should continue or not?

###  if (no):

  - then abort the script execution.

### if (yes):  

  - Initialize variables.
  - Generate parcel id.

  - Create parcel folder: `./parcel`
  - Create encryption key: `encryption.key`
  - Create parcel data file: `parcel.data`

  - If needed create output folders. `./logs` `./cache` `Parcels`

  - Debug log is created & starts: `./logs/debug.log` 
  - Parcel log is created & starts: `./logs/parcel.log`
  - Parcel data is written to: `./parcel/parcel.data`
  
### loop begins: for target in $targets; do

  - Get the target file extension or if a folder the folder name. `$extension` `$non-extension`
  
### if there are still targets: if $iteration_count -ne 0; then

  - Increment the iteration count: `iteration_count=$((iteration_count + 1))`

### if the $target is a file: `if [[ -f $target]]; then`

  - Write the target data string: `$TARGET_DATA_STRING`
  
  - encrypt the target with ***src/encrypt.sh***: `encrypt-target: $target`
  - get base file name & apply new ext. to $target var: `target="${_base}.enc"`
file1.txt ---> file1.enc (.txt is not left over.)

  - arc the target with ***arc***: `arc-target $target`
  - get base file name & apply new ext. to $target var: `target="${_base}.arc"`
file1.enc ---> file1.arc (.enc is not left over.)

  - Move $target into the parcel directory for archiving & second layer of encryption.
  `sudo mv "$target" "$parcel_directory/"`

### if the $target is a folder: `if [[ -d $target]]; then`

  - encrypt all targets. `process-files "$target" "encrypt-target"`
file/s.txt ---> file/s.enc
  
  - arc compress all targets: `process-files $target "arc-target"`
file/s.enc ---> file/s.arc

  - zip target when all sub dirs are dealt with: `zip-target $target`

  - remove the left over folder: `sudo rm -r $target`
 
  - Put $target into the parcel folder. `sudo mv ${target}.zip` 
    
### } loop over

- Write the parcel data before archiving parcel.

- Move parcel data file `parcel.data` to the `parcel_directory`

- zip the parcel/: `sudo zip -r "./parcel.zip"`

parcel/ ---> parcel.zip

- Remove the left over parcel/ folder: `sudo rm -r $parcel_directory`

- gpg encrypt the zip folder: `gpg-encrypt-target "./parcel.zip"`
parcel.zip ---> parcel.zip.gpg

- change name of parcel extension to .parcel
parcel.zip.gpg ---> parcel



## }
