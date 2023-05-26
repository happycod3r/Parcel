
### encrypt-file "$target"
```bash
  encrypt-file "$target
  local _base="$(get-base-file-name $target)"
  target="${_base}.enc"

```
**file1.txt ---> [ file1.enc, encryption.key ]**

### gpg-encrypt-file "$target"
```bash
  gpg-encrypt-file "$target"
  sudo rm $target
  target="${target}.gpg"
```
**file1.enc ---> file1.enc.gpg**
**file1.enc.gpg, encryption.key, parcel.data --->  parcel/**

**parcel/ ---> parcel.zip**
`sudo zip -r "./parcel.zip" "$parcel_directory"`

**parcel.zip ---> parcel.parcel**
`mv parcel.zip parcel.parcel`

**parcel.parcel ---> A8GDW2X650PU.parcel**
