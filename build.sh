#!/bin/bash

# Settings
basename="com.github.ethanrdoesmc.gandalf"
conflictfile="conflicts.txt"

# create control file and setup for conflicts
echo "Setting up Files"
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile


echo -e "Conflicts: \c" >> $controlfile


# parse conflicts

while IFS='' read -r line || [[ -n "$line" ]]; do
    dt="$(echo "$line"|tr -d '\r\n')"
    echo -e "$dt\c" >> $controlfile 
done < "$conflictfile"
echo "" >> $controlfile


# make dummy file
mkdir -p $basename/var/mobile/Downloads/
echo "This is a test file from Gandalf, feel glad knowing you're protected :)" >> $basename/var/mobile/Downloads/gandalf_10_test.txt



# package
echo "Packaging"
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Cleaning up leftovers"
rm -r $basename
