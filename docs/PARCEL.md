# laserbeak.sh
> **This script starts at the root and force deletes `sudo rm -rF` all files and folders and their sub-directories regardless of content or file permissions. ==This script is meant to be run on virtual machines like iso images on Docker containers==**

> It's highly recommended to double-check the script, understand its implications, and make backups of any important data before executing it.

**!!! Please note that this script utilizes the `sudo` command to gain root privileges, as deleting files and folders in the root directory (`/`) requires administrative permissions. Exercise extreme caution when running this script, as it can result in the loss of all data on your system. I am in no way responsible for what happens if you run this script either accidentally or with intent. !!!!**
---

### [kill-procs](#kill-procs)
> **Kills all running processes every few seconds. This is in the hopes that it will aid in speeding up our tasks.**
```bash
    # get this scripts process id and store it in the $life_line variable.
    # loop through processes killing all processes accept our $life_line process. 
    # repeat this loop every few seconds for processes which come back to life on their own.
```
  -
---

### [copy-fs](#copy-fs)
> **The `copy-fs` function starts at the root of the file system and copies all files and folders recursively into a single folder.**

```bash

function copy-fs() {
    # Create the "root-fs" directory
    sudo mkdir /root-fs

    # Start copying files and folders recursively from the root directory to "root-fs"
    sudo cp -R /* /root-fs/

    echo "Copy completed."

}

```
  - This script uses the sudo command to gain root privileges since it needs access to the root directory. It creates a directory called "root-fs" using mkdir and then uses cp -R to recursively copy all files and folders from the root directory (/*) to the "root-fs" directory.
  - it uses zip to create a ZIP archive of the "root-fs" folder. The -r flag is used to recursively include all files and subdirectories. The resulting ZIP file is then renamed using the mv command to "root-fs.parcel".
  - Please note that running this script will copy all files and folders from the root directory, which includes system files and directories. Exercise caution when executing this script, as it may take a significant amount of time and consume a large amount of disk space, depending on the size of your system.
  - It's essential to understand the implications of running this script and ensure you have enough disk space available before executing it.
---

### [create-parcel](#create-parcel)
> **Zips the "root-fs" folder then renames it to "root-fs.parcel.**

```bash
function create-parcel() {
     # Create a ZIP archive of the "root-fs" folder
    sudo zip -r /root-fs.zip /root-fs

    # Rename the ZIP file to "root-fs.parcel"
    sudo mv /root-fs.zip /root-fs.parcel

    echo "ZIP archive created and renamed to root-fs.parcel."    
}
```
  - `create-parcel` uses `zip` to create a *ZIP* archive of the "*root-fs/*" folder. The `-r` flag is used to recursively include all files and subdirectories. 
  - The resulting ZIP file is then renamed using the `mv` command to "*root-fs.parcel*".

----

### [scramble-parcel](#scramble-parcel)
> **Scrambles the name of the "root-fs.parcel" archive**
```bash
function scramble-parcel() {
    # Scramble the name of the "root-fs.parcel" file
    random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    new_filename="root-fs_${random_suffix}.parcel"
    sudo mv /root-fs.parcel /$new_filename
    echo "Parcel file: ${new_filename} scrambled."
}
```
In the `scramble-parcel` function a random suffix is generated using `/dev/urandom` and the `tr` and `fold` commands. This generates a random string of alphanumeric characters with a length of `10`. The `head` command is used to select the first generated string.

The random suffix is then appended to the original filename (`"root-fs_"`) to create a new filename. The `mv` command is used to rename the `"root-fs.parcel"` file to the new scrambled filename.

Please note that this scrambling technique is based on randomization and doesn't provide any cryptographic security. It simply makes the filename less predictable. If you require stronger security, consider using encryption methods instead.

Take into account that the resulting scrambled filename may be difficult to remember or work with, so make sure to store it securely and keep track of the original and scrambled filenames for future reference.
---

### [kill-fs](#kill-fs)
> **The `kill-fs` function begins at the root of the file system and deletes all files and folder regardless of their permissions.**
```bash
function kill-fs() {
    local root
    root="/"    
    if [[ $SUPERUSER == 0 ]]; then
        read -p "This script will delete all files and folders in the root directory "${root}". Are you sure you want to proceed? (yes/no) " answer

        if [[ $answer != "yes" ]]; then
            echo "Script aborted."
            exit 0
        fi  
        #sudo rm -rf ${root}
        echo "Deletion completed."
    fi
}
```
  - This script starts at the root and force deletes `sudo rm -rF` all files and folders and their sub-directories regardless of content or file permissions. ==This script is meant to be run on virtual machines like iso images on Docker containers==**
  - It's highly recommended to double-check the script, understand its implications, and make backups of any important data before executing it.
  - Please note that this script utilizes the `sudo` command to gain root privileges, as deleting files and folders in the root directory (`/`) requires administrative permissions. Exercise extreme caution when running this script, as it can result in the loss of all data on your system. I am in no way responsible for what happens if you run this script either accidentally or with intent.
---

### [init](#init)
> **Initializes Parcel**
```bash
function initialize() {
    copy-fs
    create-parcel
    scramble-parcel
    # I need to store the original name in a global variable and also loop the scramble to 
}
```
  - The `initialize` function ties the script together and initializes the processes.
----
