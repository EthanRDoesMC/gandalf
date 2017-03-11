#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

#this script will show what the package file structure looks like. used for debugging.

# Aliases
basename="io.github.ethanrdoesmc.gandalf102"
conflictfile="conflicts.txt"

# create control file and setup for conflicts
echo "Creating directories and copying files."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile


echo -n "Conflicts: " >> $controlfile


# parse conflicts

while IFS='' read -r line || [[ "$line" ]]; do
    dt="$(echo "$line"|tr -d '\r\n')"
    echo "$dt" >> $controlfile 
done < "$conflictfile"
echo -n "" >> $controlfile


# make managerlist file - make sure to update based on version
mkdir -p $basename/var/mobile/Downloads/ManagerList
echo "Gandalf for Yalu102 (2.0 Beta 1) was installed via Manager." >> $basename/var/mobile/Downloads/ManagerList/io.github.ethanrdoesmc.gandalf102.txt

echo "This is what the package file structure looks like."