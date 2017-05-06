##!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases
basename="io.github.gandalf.icons"

# create control file and setup for conflicts
echo "Creating directories and copying files."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control $controlfile

mkdir -p "$basename/Applications/Cydia.app/Sections/"
cp Misc.png $basename/Applications/Cydia.app/Sections/Misc.png
cp Gandalf102.png $basename/Applications/Cydia.app/Sections/Gandalf102.png
cp Portal.png $basename/Applications/Cydia.app/Sections/Gandalf_For_YaluX_AKA_Mach_Portal.png

# package
echo "Creating package."
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Removing temporary folders and files."
rm -r $basename
