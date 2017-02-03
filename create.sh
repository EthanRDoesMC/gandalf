#!/bin/bash


echo "Setting up Files"
# create control file and setup for conflicts
controlfile="Gandalf10/DEBIAN/control"
mkdir -p "Gandalf10/DEBIAN/"
cp control Gandalf10/DEBIAN/control


echo -e "Conflicts: \c" >> $controlfile


# parse conflicts

while IFS='' read -r line || [[ -n "$line" ]]; do
	dt="$(echo "$line"|tr -d '\n')"
	echo "$dt"
    echo -e "$dt\c" >> $controlfile 
done < "conflicts.txt"
echo "" >> $controlfile


# make dummy file
mkdir -p Gandalf10/var/mobile/Downloads/
echo "This is a dummy file from Gandalf iOS 10" >> Gandalf10/var/mobile/Downloads/dummy.txt



# package
echo "Packaging"
dpkg-deb -Zgzip -b Gandalf10


# cleanup
echo "Cleaning up leftovers"
rm -r Gandalf10