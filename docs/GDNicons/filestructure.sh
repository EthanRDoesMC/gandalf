#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases
basename="io.github.ethanrdoesmc.icons"
conflictfile="conflicts.txt"

# create control file and setup for conflicts
echo "Creating directories and copying files."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile

#get icons and paste in cydia
mkdir -p "$basename/Applications/Cydia.app/Sections/"
cp Manager10.png $basename/Applications/Cydia.app/Sections/Manager10.png
cp Manager10.png $basename/Applications/Cydia.app/Sections/Manager_Addons.png

# make managerlist file - make sure to update based on version
mkdir -p $basename/var/mobile/Downloads/ManagerList
echo "Repo icons for EthanR's Repo installed not through manager tho" >> $basename/var/mobile/Downloads/ManagerList/io.github.ethanrdoesmc.icons.txt

echo "Done"