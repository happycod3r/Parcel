
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
