#!/bin/bash

# Settings
basename="Gandalf10"
conflictfile="conflictsnonewlines.txt"

# create control file and setup for conflicts
echo "Setting up Files"
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile


echo "Conflicts: \c" >> $controlfile


# parse conflicts

while IFS='' read -r line || [[ -n "$line" ]]; do
	dt="$(echo "$line"|tr -d '\r\n')"
    echo "$dt\c" >> $controlfile 
done < "$conflictfile"
echo "" >> $controlfile


# make dummy file
mkdir -p $basename/var/mobile/Downloads/
echo "This is a dummy file from Gandalf iOS 10" >> $basename/var/mobile/Downloads/gandalf_10_dummy.txt



# package
echo "Packaging"
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Cleaning up leftovers"
rm -r $basename
