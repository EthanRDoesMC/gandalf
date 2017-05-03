#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases

basename="io.github.ethanrdoesmc.gandalf102" #identifier (ios internal name)
conflictfile="conflicts102.txt" # Name of conflictsfile
scriptname="gandalf102" #name of hold script
productname="Gandalf 102" #name of gandalf for user (shown in terminal)

# Define controlfile (set variables)
packagename="Gandalf for Yalu102" # Name shown in Cydia

########################
packageversion="2.3.5" # Here edit the versionnumber
########################

packagereplaces="com.enduniverse.cydiaextenderplus, com.github.ethanrdoesmc.gandalf, com.github.ethanrdoesmc.gandalf102"
packagedescription='Some tweaks may break jailbreaks. Let this tweak say "You Shall Not Pass!" to incompatible tweaks and you can sit back and have fun with your jailbreak.'
packagedepiction='https://ethanrdoesmc.github.io/gandalf/docs/depictions/?p=io.github.ethanrdoesmc.gandalf102'
maintainer="EthanRDoesMC <ethanrdoesmc@gmail.com>"
author="EthanRDoesMC <ethanrdoesmc@gmail.com>"
depends="firmware (>=10.0), sudo, com.officialscheduler.mterminal"
section="Manager_Addons"

# Show user what he's trying to compile


echo "Welcome to $productname! You are now compiling $basename; Version $packageversion. The name '$packagename' will be shown in Cydia. The name of the hold script will be '$scriptname'. I hope that's all correct. If not: please abort this script within 3 seconds. Otherwise just wait."

sleep 3

# create control file and setup for conflicts
echo "Creating directories and copying files..."
# Create control file
mkdir -p "$basename/DEBIAN/"
controlfile="$basename/DEBIAN/control"
touch $controlfile #create it (just for sure)
echo "Package: $basename" > $controlfile #Delete whole content of the file and add identifier
echo "Name: $packagename" >> $controlfile
echo "Version: $packageversion" >> $controlfile
echo "Architecture: iphoneos-arm" >> $controlfile #better not to change this...
echo "Replaces: $packagereplaces" >> $controlfile
echo "Description: $packagedescription" >> $controlfile
echo "Depiction: $packagedepiction" >> $controlfile
echo "Maintainer: $maintainer" >> $controlfile
echo "Author: $author" >> $controlfile
echo "Depends: $depends" >> $controlfile
echo "Section: $section" >> $controlfile

#for debugging:
# cat $controlfile

# cp control102 $controlfile

#CODE CLEANUP NEEDS TO HAPPEN. -> Define all variables at beginning?
#We aren't adhering to standards very well.


# parse conflicts
# works on RHEL/CentOS -1Conan
conflicts=$(cat $conflictfile | sed ':a;N;$!ba;s/\n/,\ /g')
echo "Breaks: ${conflicts}" >> $controlfile
#for debugging:

#cat $controlfile


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
