#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases

basename="io.github.ethanrdoesmc.gandalf102" #identifier (ios internal name)
conflictfile="conflicts102.txt" # Name of conflictsfile
scriptname="gandalf102" #name of hold script
productname="Gandalf 102" #name of gandalf for user (shown in terminal)

# create control file and setup for conflicts
echo "Creating directories and copying files..."
controlfile="$basename/DEBIAN/control"
mkdir -p "$basename/DEBIAN/"
cp control102 $controlfile

#CODE CLEANUP NEEDS TO HAPPEN. -> Define all variables at beginning?
#We aren't adhering to standards very well.


# parse conflicts
# works on RHEL/CentOS -1Conan
conflicts=$(cat conflicts102.txt | sed ':a;N;$!ba;s/\n/,\ /g')
echo "Breaks: ${conflicts}" >> $controlfile


echo "Making the TAR..."
# better name everything lowercase (you might know the small fiasco with Gandalf.app and gandalf.app? -jonisc)
tar -czf Gandalf.app.tar.gz gandalf.app
echo "Creating folders..."
mkdir -p $basename/Applications
mkdir -p $basename/var/mobile/Downloads/Gandalf102
echo "Moving TAR around..."
mv Gandalf.app.tar.gz $basename/var/mobile/Downloads/Gandalf102
echo "Copying remove and install scripts..."
cp prerm $basename/DEBIAN
cp postinst $basename/DEBIAN
# edit postinst
echo "Adding right hold command to install script..."
sed -i "s/gAndAlfh0LdC0mMand/$scriptname/" $basename/DEBIAN/postinst


# Do the scripts
###

echo "Scripted Scripting is Scriptatious and Scriptmatic"
echo "or simply: Messing around with the hold script..."
mkdir -p $basename/usr/bin
cp $scriptname $basename/usr/bin
echo "Editing hold script..."
sed -i "s/iDenT1FIEr/$basename/" $basename/usr/bin/$scriptname
sed -i "s/vErs10Nname/$productname/" $basename/usr/bin/$scriptname
### might work with sed (works on UBUNTU)
#RIP GANDALF MANAGER
#NOBODY LIKED YOU
#LONG LIVE SETUP MANAGER
#/kill gandalfmanager


# package
echo "Almost finished..."
echo "Creating package..."
dpkg-deb -Zgzip -b $basename


# cleanup
echo "Removing temporary folders and files..."
rm -r $basename

sleep 1

echo "YOU DID IT!"

sleep 1

echo "YOU AWESOME ROBOCRAFTER"
