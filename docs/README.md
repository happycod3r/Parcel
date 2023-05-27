![Alt](../res/Parcel.png)

# .parcel

> Parcel is an archiving and encrypting algorythm used to store and protect files in an easy to use way. Just run selected files and folders through Parcel and it will create a ***.parcel*** archive containg encrypted versions of all of your files and data also retaining the original directory structure, permissions and ownership.

## Table Of Contents

---
## About
I have created the ***.parcel*** archive after my companies data was breached. I wanted to create something in which bad actors wouldn't recognize - at least right away. Parcel is not 100% hacker/bad actor proof by any means as nothing really is, but it's my way of trying to create something as close to it as possible. In order to do this I employed multiple layers of encryption, archiving, scrambling methods and ID protected access in order to create as many layers as possible on top of the original data so that anyone trying to get the raw data in a ***.parcel*** archive will have a truly hard time reverse engineering it and getting that data.
Although what happens under the hood of Parcel is complex, Parcel is as easy to use as any other archiving methods such as `.rar` or `.zip` archives. 

---
## Archiving/Encryption Methods

--- 

## Archiving/Encryption Control Flow

> 1) File is encrypted with ***encryption.sh*** and the ***encryption.key*** file is created 
### encrypt-file "$target"
```bash
  encrypt-file "$target
  local _base="$(get-base-file-name $target)"
  target="${_base}.enc"

```
**file1.txt ---> [ file1.enc, encryption.key ]**
> 2) the encrypted ***.enc*** file is encrypted again.
### gpg-encrypt-file "$target"
```bash
  gpg-encrypt-file "$target"
  sudo rm $target
  target="${target}.gpg"
```
**file1.enc ---> file1.enc.gpg**


> 3) The ***file1.enc.gpg***, ***encryption.key***, ***parcel.data*** files are stored in the parcel folder ***parcel/***
**file1.enc.gpg, encryption.key, parcel.data --->  parcel/**

> 4) Next the parcel folder ***parcel/*** is archived using ***zip*** to bundle the encrypted parcel files/folders.
**parcel/ ---> parcel.zip**
`sudo zip -r "./parcel.zip" "$parcel_directory"`

> 5) Once zipped the ***parcel.zip*** is renamed to ***parcel.parcel*** to throw off the original extension. The ***.zip*** extension will only be partially hidden by just renaming it though so it isn't completely hidden , but still adds another small visual layer of deception to unexperienced prying people who won't know to check the file details. 
**parcel.zip ---> parcel.parcel**
`mv parcel.zip parcel.parcel`

> 6) Then a 10byte ID is created and used as the new .parcel archive name.
**parcel.parcel ---> A8GD2X650P.parcel**
`sudo mv "./parcel.parcel" "./${parcel_name}"`

> 7) Lastly the ***.parcel*** is archived one last time using 

--- 
