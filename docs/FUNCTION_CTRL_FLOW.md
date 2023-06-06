
# Function Execution Control Flow

### This file is the result of placing a function call to a function that simply writes the name of the calling function - and if it has an argument, it's argument too - in each function and then running parcel with a sigle test file called **t1.txt**.
--- 

<br/>

## Command:
```bash
parcel t1.txt
```
---

<br/>

## Result:

> ### **parcel/parcel**
- #### start-parcel() { ***[t1.txt](#)*** }

> ### **parcel/src/_init.sh**
- #### sec-gate1()
- #### encode()
- #### encode()

> ### **parcel/src/_parcel.sh**
- #### parcel() { ***[t1.txt](#)*** }
- #### make-encryption-key()

> ### **parcel/src/encrypt.sh**
- #### main()

> ### **parcel/src/_parcel.sh**
- #### write-parcel-data() { ***[-------- Mon 05 Jun 2023 10:54:10 PM EDT --------](#)*** }
- #### encrypt-target() { ***[t1.txt](#)*** }
- #### get-base-file-name() { ***[t1.txt](#)*** }
- #### get-target-directory() { ***[t1.txt](#)*** }

> ### **parcel/src/encrypt.sh**
- #### main()

> ### **parcel/src/_parcel.sh**
- #### arc-target() { ***[t1.txt.enc](#)*** }
- #### get-base-file-name() { ***[t1.txt.enc](#)*** }
- #### get-target-directory() { ***[t1.txt.enc](#)*** }
- #### get-base-file-name() { ***[t1.txt.enc](#)*** }
- #### write-parcel-data() { ***[t1.txt : .txt : KUQBP4UJB3 : KUQBP4UJB3.parcel](#)*** }
- #### write-parcel-data() { ***[-------------------- 10:54:10 -------------------](#)*** }
