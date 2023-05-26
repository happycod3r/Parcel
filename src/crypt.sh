#!/bin/bash

#this is a script to encrypt all files in a user given directory

#handle commandline arguments

# encrypt all files in a given directory.
#USAGE:  Encryption - bash crypt.sh -E my/dir
#        Decryption - bash crypt.sh -D my/dir

if [ $# -eq 0 ]
then
	echo "\e[31mUsage \e[39m: crypt -[E/D]"
	echo "D- Decrypt files"
	echo "E- Encrypt files"
	exit 1	
fi

if [ $1 != '-E' ] && [ $1 != '-D' ]
then
	echo "Invalid argument $1"
	exit 1
fi


#read path of the directory from user
echo -n "Directory path : "
read path


#read password from user
echo -n "Password : "
stty -echo
read  pass
echo
stty echo
if [ $1 != '-D' ]
then
	echo -n "Confirm Password : "
	stty -echo
	read  pass2
	stty echo
	echo
	
	if [ $pass != $pass2 ]
	then
        	echo "\e[91mPassword mismatch !"
      		exit 1
	fi


else
	echo ""
fi
 
files="$path/*"


#loop through files in the given directory
for f in $files
do
	if [ $1 != '-D' ]
	then
       		openssl enc -aes-256-cbc -salt -in "$f" -out "$f.en" -k $pass
		echo "\e[92m$f encypted"
		rm -r  "$f"
	else
        	openssl enc -aes-256-cbc -d -in "$f" -out "$f.d" -k $pass 2> /dev/null
		if [ $? -ne 1 ]
		then
			rm -r "$f"
			rename 's/\.en\.d//' "$f.d"
			echo "\e[92m$f Decrypted !"
		else
			rm "$f.d"
			echo "\e[91mDecryption Failed !"
	
		fi

	fi

done	


