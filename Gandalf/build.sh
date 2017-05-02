#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases
basename="io.github.ethanrdoesmc.gandalf102" #IDENTIFIER
conflictfile="conflicts102.txt"
scriptname="gandalf102" #NAME OF THE SCRIPT
productname="Gandalf 102" #NAME OF GANDALF SHOWN IN TERMINAL

# create control file and setup for conflicts
echo "Creating directories and copying files."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control102 $controlfile




# parse conflicts
# works on RHEL/CentOS -1Conan
conflicts=$(cat conflicts102.txt | sed ':a;N;$!ba;s/\n/,\ /g')
echo "Breaks: ${conflicts}" >> $controlfile


echo "Making the TAR..."
tar -czf Gandalf.app.tar.gz Gandalf.app
mkdir -p $basename/Applications
mkdir -p $basename/var/mobile/Downloads/Gandalf102
mv Gandalf.app.tar.gz $basename/var/mobile/Downloads/Gandalf102
cp prerm $basename/DEBIAN
cp postinst $basename/DEBIAN


# Do the scripts
###

echo "Scripted Scripting is Scriptatious and Scriptmatic"
mkdir -p $basename/usr/bin
cp $scriptname $basename/usr/bin
sed -i "s/iDenT1FIEr/$basename/" $basename/usr/bin/$scriptname
sed -i "s/vErs10Nname/$productname/" $basename/usr/bin/$scriptname
### might work with sed (works on UBUNTU)
#RIP GANDALF MANAGER
#NOBODY LIKED YOU
#LONG LIVE SETUP MANAGER
#/kill gandalfmanager


# package
echo "Creating package."
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Removing temporary folders and files."
rm -r $basename

sleep 1

echo "YOU DID IT"

sleep 1

echo "YOU AWESOME ROBOCRAFTER"
