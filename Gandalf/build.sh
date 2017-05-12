#!/bin/bash
# 
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)
echo "We're trying something new! Put in the version you want in version.txt (either as 'x' or 102) and we'll have one build.sh script!"
echo "sleeping for 5 seconds"
sleep 5
VER=$(cat version.txt)

# Config
PKG_VERSION="2.5.5" #Bump this everytime you update something.
CONFLICTS_FILE="$VER/conflicts.txt"
NAME=$(cat $VER/name.txt)
FIRM=$(cat $VER/firmware.txt)
#DO NOT TOUCH! (Unless you have a good reason...)
#Variable format is "PKG_FIELDNAME"
PKG_PACKAGE="io.github.ethanrdoesmc.gandalf$VER"
PKG_NAME="Gandalf for $NAME"
PKG_DESCRIPTION="Some tweaks may break jailbreaks. Let this tweak say
  \"You Shall Not Pass!\" to incompatible tweaks and you can sit back and have
  fun with your jailbreak."
PKG_DEPICTION="https://ethanrdoesmc.github.io/gandalf/depictions/?p=io.github.ethanrdoesmc.gandalf102"
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_SECTION=$(cat $VER/section.txt)
PKG_DEPENDS="firmware $FIRM, sudo, com.officialscheduler.mterminal, mobilesubstrate"
PKG_REPLACES="com.enduniverse.cydiaextenderplus, com.github.ethanrdoesmc.gandalf, com.github.ethanrdoesmc.gandalf102"
PKG_ARCHITECTURE='iphoneos-arm'
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed ':a;N;$!ba;s/\n/,\ /g')


#Main script

#Start message
echo "Started packaging ${PKG_NAME}"

#Prepare the package structure
echo "Creating package structure..."

mkdir "${PKG_PACKAGE}"
mkdir "${PKG_PACKAGE}/DEBIAN"
mkdir -p "${PKG_PACKAGE}/usr/bin"
mkdir -p "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Create the control file
echo "Creating the control file..."

cat <<EOF > "${PKG_PACKAGE}/DEBIAN/control";
Package: ${PKG_PACKAGE}
Name: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${PKG_ARCHITECTURE}
Replaces: ${PKG_REPLACES}
Description: ${PKG_DESCRIPTION}
Depiction: ${PKG_DEPICTION}
Maintainer: ${PKG_MAINTAINER}
Author: ${PKG_AUTHOR}
Depends: ${PKG_DEPENDS}
Section: ${PKG_SECTION}
Breaks: ${PKG_BREAKS}
EOF


#Compress the application
echo "Compressing and moving Gandalf.app..."

tar -czf "Gandalf.app.tar.gz" "Gandalf.app"
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cp "gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable 
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"

echo "If you have anything else you need to put into Gandalf, now's the time. You have 15 seconds from the moment this message appears."
sleep 15

#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"

echo "Packaging done."
echo "Filename: ${PKG_PACKAGE}.deb"
