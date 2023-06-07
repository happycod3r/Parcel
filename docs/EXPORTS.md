# Global Environment Variables

## The following is a list of all global environment variables set by Parcel after running the `parcel` command for the first time. 
---
<br/>

### [PRCL_HIDE](#prcl_hide)
* Default is `false`.
* Setting this to `true` will make parcel attempt to hide itself by disguising itself as something else, such as another random folder or file type.

### [PRCL_EXPORT_GLOBALS](#prcl_export_globals)
* Default is `true`.
* Initially set to `false` for security, but if you'r not worried about security, setting this to `true` will allow the global environment variables to be exported.
The changes will take effect next time you use the `parcel` command.

### [PRCL_DEACTIVATE](#prcl_deactivate)
* Default is `false`.
* Setting `PRCL_DEACTIVATE` to `true` will deactivate Parcel making it so that Parcels internals will become unreachable in the function execution control flow when the `parcel` command is run. 
* This will also make it seem as though Parcel isn't on the computer at all by echoing the `command not found` error message when executing `parcel`.  
* Setting `$PRCL_DEACTIVATE` to `true` will also automatically set `$PRCL_EXPORT_GLOBALS` to `false`.
* The only global environment variable that will still be exported after setting this to true will be this one, so that you have a way to reactivate Parcel.

### [PRCL_PIN_ON](#prcl_export_globals)
* Default is `true`.
* Controls wether or not you need to use a pin to use Parcel. I would suggest using it, but again, if you are not interested in security it may just be a hinderance.

### [PRCL_PARCELS_DIRECTORY](#prcl_parcels_directory)
* Default is `parcel/Parcels` 
* Allows you to specify the path to where you want the Parcels directory.

### [PRCL_CONFIG_FOLDER](#prcl_config_folder)
* Default is `$HOME/.config/parcel`.
* Allows you to specify where config files should go.

### [PRCL_ENCRYPTION](#prcl_encryption)
* Default is `true`
* Turns encryption on and off. Changes take effect on the next execution of the `parcel` command.

### [PRCL_LAST_PARCEL](#prcl_last_parcel)
* Initially set to `"undefined"`.
* Will always contain the file name of the last .parcel created.

### [PRCL_PARCEL_COUNT](#prcl_parcel_count)
* Returns the current number of .parcels in the directory specified with the `$PRCL_PARCELS_DIRECTORY` environment variable.

### [PRCL_VERSION](#prcl_version)
* Returns `Parcel v1.0.0`
* Will always contain the version of Parcel being used.
* You can also achieve this by running `parcel -v` or `parcel --version`
