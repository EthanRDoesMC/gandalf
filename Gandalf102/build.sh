#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases
basename="io.github.ethanrdoesmc.gandalf102"
conflictfile="conflicts.txt"

# create control file and setup for conflicts
echo "Creating directories and copying files."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile


echo -n "Breaks: " >> $controlfile


# parse conflicts

while IFS='' read -r line || [[ "$line" ]]; do
    dt="$(echo "$line"|tr -d '\r\n')"
    echo "$dt" >> $controlfile 
done < "$conflictfile"
echo -n "" >> $controlfile
echo "Making The Tar"
tar -czf gandalf.app.tar.gz gandalf.app
mkdir -p $basename/Applications
mkdir -p $basename/var/mobile/Downloads/Gandalf102
mv gandalf.app.tar.gz $basename/var/mobile/Downloads/Gandalf102
cp prerm $basename/DEBIAN
cp postinst $basename/DEBIAN


# Do the scripts
echo "Doing The Scripts"
mkdir -p $basename/usr/bin
cp gandalf102-hold $basename/usr/bin
cp gandalf102-rmhold $basename/usr/bin

# make managerlist file - make sure to update based on version
echo "Gandalf for Yalu102 (2.0 Delta 3) was installed via Manager." >> $basename/var/mobile/Downloads/Gandalf102/io.github.ethanrdoesmc.gandalf102.txt


# package
echo "Creating package."
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Removing temporary folders and files."
rm -r $basename

sleep 1

echo "We made it"